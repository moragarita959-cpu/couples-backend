import 'package:flutter/material.dart';

class HomeInfoCards extends StatelessWidget {
  const HomeInfoCards({
    super.key,
    required this.loveDays,
    required this.distanceText,
    required this.nextAnniversaryText,
    required this.isDistanceEnabled,
    required this.onToggleDistance,
    required this.myLocationVisible,
    required this.onToggleMyLocationVisible,
    this.myLatitude,
    this.myLongitude,
    this.partnerLatitude,
    this.partnerLongitude,
    this.myLocationLabel,
    this.partnerLocationLabel,
  });

  final int loveDays;
  final String distanceText;
  final String nextAnniversaryText;
  final bool isDistanceEnabled;
  final VoidCallback onToggleDistance;
  final bool myLocationVisible;
  final ValueChanged<bool> onToggleMyLocationVisible;
  final double? myLatitude;
  final double? myLongitude;
  final double? partnerLatitude;
  final double? partnerLongitude;
  final String? myLocationLabel;
  final String? partnerLocationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '关系信息',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3E2A30),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _InfoMiniCard(
                title: '恋爱天数',
                value: '第 $loveDays 天',
                helper: '一起走过的日子',
                icon: Icons.favorite_rounded,
                valueColor: const Color(0xFFB63E5A),
                backgroundColor: const Color(0xFFFFF4F8),
                iconColor: const Color(0xFFE85A7A),
                emphasize: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoMiniCard(
                title: '距离',
                value: distanceText,
                helper: isDistanceEnabled ? '已开启首页显示' : '距离功能未开启',
                icon: Icons.social_distance_outlined,
                actionText: isDistanceEnabled ? '关闭' : '开启',
                onActionTap: onToggleDistance,
                iconColor: isDistanceEnabled
                    ? const Color(0xFFE85A7A)
                    : const Color(0xFF9A9A9A),
                backgroundColor: isDistanceEnabled
                    ? Colors.white
                    : const Color(0xFFF8F8F8),
                borderColor: isDistanceEnabled
                    ? const Color(0x22000000)
                    : const Color(0x14000000),
                valueColor: isDistanceEnabled
                    ? const Color(0xFF3E2A30)
                    : const Color(0x883E2A30),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoMiniCard(
                title: '最近纪念日',
                value: nextAnniversaryText,
                helper: '下一次想一起庆祝',
                icon: Icons.auto_awesome,
                valueColor: const Color(0xFF8D4B67),
                backgroundColor: const Color(0xFFFFF8FB),
                iconColor: const Color(0xFFD36B8A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _LocationPreviewCard(
          myLatitude: myLatitude,
          myLongitude: myLongitude,
          partnerLatitude: partnerLatitude,
          partnerLongitude: partnerLongitude,
          myLocationVisible: myLocationVisible,
          myLocationLabel: myLocationLabel,
          partnerLocationLabel: partnerLocationLabel,
          onToggleMyLocationVisible: onToggleMyLocationVisible,
        ),
      ],
    );
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard({
    required this.myLatitude,
    required this.myLongitude,
    required this.partnerLatitude,
    required this.partnerLongitude,
    required this.myLocationVisible,
    required this.myLocationLabel,
    required this.partnerLocationLabel,
    required this.onToggleMyLocationVisible,
  });

  final double? myLatitude;
  final double? myLongitude;
  final double? partnerLatitude;
  final double? partnerLongitude;
  final bool myLocationVisible;
  final String? myLocationLabel;
  final String? partnerLocationLabel;
  final ValueChanged<bool> onToggleMyLocationVisible;

  @override
  Widget build(BuildContext context) {
    final hasMe = myLatitude != null && myLongitude != null;
    final hasPartner = partnerLatitude != null && partnerLongitude != null;
    final mapUrl = hasMe
        ? _staticMapUrl(
            centerLat: myLatitude!,
            centerLng: myLongitude!,
            myLat: myLatitude,
            myLng: myLongitude,
            partnerLat: partnerLatitude,
            partnerLng: partnerLongitude,
          )
        : null;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1F000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, size: 16, color: Color(0xFF8D4B67)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '位置',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3E2A30)),
                ),
              ),
              Switch.adaptive(
                value: myLocationVisible,
                onChanged: onToggleMyLocationVisible,
              ),
              const Text('隐藏我位置', style: TextStyle(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '我：${myLocationLabel?.trim().isNotEmpty == true ? myLocationLabel! : (hasMe ? "${myLatitude!.toStringAsFixed(4)}, ${myLongitude!.toStringAsFixed(4)}" : "未定位")}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF5E4B52)),
          ),
          Text(
            'TA：${partnerLocationLabel?.trim().isNotEmpty == true ? partnerLocationLabel! : (hasPartner ? "${partnerLatitude!.toStringAsFixed(4)}, ${partnerLongitude!.toStringAsFixed(4)}" : "对方隐藏或未定位")}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF5E4B52)),
          ),
          const SizedBox(height: 8),
          if (mapUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                mapUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _MapPlaceholder(
                  height: 140,
                  centerLat: myLatitude!,
                  centerLng: myLongitude!,
                  myLat: myLatitude,
                  myLng: myLongitude,
                  partnerLat: partnerLatitude,
                  partnerLng: partnerLongitude,
                  title: '地图预览不可用',
                ),
              ),
            )
          else
            SizedBox(
              height: 80,
              child: hasMe
                  ? _MapPlaceholder(
                      height: 80,
                      centerLat: myLatitude!,
                      centerLng: myLongitude!,
                      myLat: myLatitude,
                      myLng: myLongitude,
                      partnerLat: partnerLatitude,
                      partnerLng: partnerLongitude,
                      title: '地图预览（离线占位）',
                      compact: true,
                    )
                  : const Center(child: Text('开启定位后显示地图')),
            ),
        ],
      ),
    );
  }

  String _staticMapUrl({
    required double centerLat,
    required double centerLng,
    double? myLat,
    double? myLng,
    double? partnerLat,
    double? partnerLng,
  }) {
    final markers = <String>[];
    if (myLat != null && myLng != null) {
      markers.add('$myLat,$myLng,lightblue1');
    }
    if (partnerLat != null && partnerLng != null) {
      markers.add('$partnerLat,$partnerLng,red');
    }
    final markerPart = markers.map((e) => '&markers=$e').join();
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=$centerLat,$centerLng&zoom=11&size=600x260$markerPart';
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.height,
    required this.centerLat,
    required this.centerLng,
    required this.title,
    this.myLat,
    this.myLng,
    this.partnerLat,
    this.partnerLng,
    this.compact = false,
  });

  final double height;
  final double centerLat;
  final double centerLng;
  final String title;
  final double? myLat;
  final double? myLng;
  final double? partnerLat;
  final double? partnerLng;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    String line(String label, double? lat, double? lng) {
      if (lat == null || lng == null) {
        return '$label：—';
      }
      return '$label：${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }

    final body = compact
        ? <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: Color(0xFF5E4B52),
              ),
            ),
            Text(
              '${centerLat.toStringAsFixed(4)}, ${centerLng.toStringAsFixed(4)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6A72)),
            ),
          ]
        : <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xFF5E4B52),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '中心：${centerLat.toStringAsFixed(4)}, ${centerLng.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A6A72)),
            ),
            const SizedBox(height: 2),
            Text(
              line('我', myLat, myLng),
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A6A72)),
            ),
            Text(
              line('TA', partnerLat, partnerLng),
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A6A72)),
            ),
          ];

    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 6 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF2EDF6),
            Color(0xFFE8F0FA),
            Color(0xFFFDF5F0),
          ],
        ),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: body,
      ),
    );
  }
}

class _InfoMiniCard extends StatelessWidget {
  const _InfoMiniCard({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    this.actionText,
    this.onActionTap,
    this.iconColor = const Color(0xFFE85A7A),
    this.valueColor = const Color(0xFF3E2A30),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0x1F000000),
    this.emphasize = false,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Color iconColor;
  final Color valueColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 136,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0x8F3E2A30),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                    color: valueColor,
                    height: 1.24,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  helper,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0x783E2A30),
                    fontSize: 11.2,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB63E5A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
