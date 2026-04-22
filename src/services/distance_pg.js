const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

async function ensureCoupleMember(client, coupleId, currentUserId) {
  const result = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  const couple = result.rows[0];
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
  const partnerUserId = currentUserId === couple.user1_id ? couple.user2_id : couple.user1_id;
  return { partnerUserId };
}

function haversineKm(lat1, lng1, lat2, lng2) {
  const toRad = (d) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

async function updateDistanceLocationPg(pool, {
  coupleId,
  currentUserId,
  latitude,
  longitude,
  locationLabel,
}) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const lat = Number(latitude);
  const lng = Number(longitude);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    throw new AppError('invalid_request', 'latitude and longitude must be valid numbers');
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureCoupleMember(client, trimmedCoupleId, trimmedCurrentUserId);
    const label = String(locationLabel || '').trim();
    await client.query(
      `
      INSERT INTO distance_locations (couple_id, user_id, latitude, longitude, location_label, updated_at)
      VALUES ($1,$2,$3,$4,$5,$6)
      ON CONFLICT (couple_id, user_id) DO UPDATE SET
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        location_label = EXCLUDED.location_label,
        updated_at = EXCLUDED.updated_at
      `,
      [trimmedCoupleId, trimmedCurrentUserId, lat, lng, label, new Date().toISOString()],
    );
    await client.query('COMMIT');
    return { ok: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function setDistanceVisibilityPg(pool, { coupleId, currentUserId, isVisible }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const visible = isVisible !== false;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureCoupleMember(client, trimmedCoupleId, trimmedCurrentUserId);
    await client.query(
      `
      INSERT INTO distance_locations (couple_id, user_id, latitude, longitude, is_visible, updated_at)
      VALUES ($1,$2,$3,$4,$5,$6)
      ON CONFLICT (couple_id, user_id) DO UPDATE SET
        is_visible = EXCLUDED.is_visible,
        updated_at = EXCLUDED.updated_at
      `,
      [trimmedCoupleId, trimmedCurrentUserId, 0, 0, visible, new Date().toISOString()],
    );
    await client.query('COMMIT');
    return { ok: true, isVisible: visible };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function getDistanceInfoPg(pool, { coupleId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const client = await pool.connect();
  try {
    const { partnerUserId } = await ensureCoupleMember(client, trimmedCoupleId, trimmedCurrentUserId);
    const meRes = await client.query(
      'SELECT latitude, longitude, is_visible, location_label, updated_at FROM distance_locations WHERE couple_id = $1 AND user_id = $2',
      [trimmedCoupleId, trimmedCurrentUserId],
    );
    const partnerRes = await client.query(
      'SELECT latitude, longitude, is_visible, location_label, updated_at FROM distance_locations WHERE couple_id = $1 AND user_id = $2',
      [trimmedCoupleId, partnerUserId],
    );
    if (meRes.rowCount === 0 || partnerRes.rowCount === 0) {
      return {
        distanceKm: null,
        me: meRes.rowCount > 0
            ? {
                latitude: Number(meRes.rows[0].latitude),
                longitude: Number(meRes.rows[0].longitude),
                isVisible: meRes.rows[0].is_visible === true,
                label: meRes.rows[0].location_label || '',
                updatedAt: meRes.rows[0].updated_at,
              }
            : null,
        partner: null,
      };
    }
    const me = meRes.rows[0];
    const partner = partnerRes.rows[0];
    const partnerVisible = partner.is_visible === true;
    const hasCoords =
      Number.isFinite(Number(me.latitude)) &&
      Number.isFinite(Number(me.longitude)) &&
      Number.isFinite(Number(partner.latitude)) &&
      Number.isFinite(Number(partner.longitude));
    const distanceKm =
      partnerVisible && hasCoords
        ? haversineKm(
            Number(me.latitude),
            Number(me.longitude),
            Number(partner.latitude),
            Number(partner.longitude),
          )
        : null;
    return {
      distanceKm,
      me: {
        latitude: Number(me.latitude),
        longitude: Number(me.longitude),
        isVisible: me.is_visible === true,
        label: me.location_label || '',
        updatedAt: me.updated_at,
      },
      partner: partnerVisible
          ? {
              latitude: Number(partner.latitude),
              longitude: Number(partner.longitude),
              isVisible: true,
              label: partner.location_label || '',
              updatedAt: partner.updated_at,
            }
          : {
              latitude: null,
              longitude: null,
              isVisible: false,
              label: partner.location_label || '',
              updatedAt: partner.updated_at,
            },
    };
  } finally {
    client.release();
  }
}

module.exports = {
  updateDistanceLocationPg,
  setDistanceVisibilityPg,
  getDistanceInfoPg,
};
