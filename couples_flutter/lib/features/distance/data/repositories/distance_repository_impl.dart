import 'dart:io';

import 'package:geolocator/geolocator.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/distance_info.dart';
import '../../domain/repositories/distance_repository.dart';
import '../datasources/distance_mock_data_source.dart';

class DistanceRepositoryImpl implements DistanceRepository {
  const DistanceRepositoryImpl(this._dataSource);

  final DistanceMockDataSource _dataSource;
  static final ApiClient _apiClient = ApiClient();

  @override
  Future<DistanceInfo> getDistanceInfo() async {
    final local = await _dataSource.getDistanceInfo();
    if (!local.isEnabled) {
      return local;
    }

    final identity = await _dataSource.loadIdentityContext();
    final userId = identity.$1;
    final coupleId = identity.$2;
    if (userId == null || coupleId == null) {
      return local;
    }

    if (!Platform.isAndroid) {
      final pulled = await _pullCloudDistanceWithRetry(
        coupleId: coupleId,
        currentUserId: userId,
      );
      if (pulled != null) {
        final t = pulled.distanceText?.trim();
        if (t != null && t.isNotEmpty) {
          await _dataSource.updateDistanceText(t);
        }
        return pulled;
      }
      final hint = await _dataSource.updateDistanceText(
        local.distanceText?.trim().isNotEmpty == true
            ? local.distanceText!.trim()
            : '当前平台仅 Android 自动上报坐标；已尝试同步云端距离',
      );
      return DistanceInfo(
        isEnabled: hint.isEnabled,
        distanceText: hint.distanceText,
      );
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _dataSource.updateDistanceText('定位服务未开启');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _dataSource.updateDistanceText('定位权限未开启');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _apiClient.updateDistanceLocation(
        coupleId: coupleId,
        currentUserId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        locationLabel: '我的位置',
      );
      final pulled = await _pullCloudDistanceWithRetry(
        coupleId: coupleId,
        currentUserId: userId,
      );
      if (pulled != null) {
        final t = pulled.distanceText?.trim();
        if (t != null && t.isNotEmpty) {
          await _dataSource.updateDistanceText(t);
        }
        return pulled;
      }
      return _dataSource.updateDistanceText('距离同步失败');
    } catch (_) {
      return _dataSource.updateDistanceText('距离同步失败');
    }
  }

  Future<DistanceInfo?> _pullCloudDistanceWithRetry({
    required String coupleId,
    required String currentUserId,
  }) async {
    const delaysMs = <int>[0, 220, 520];
    DistanceInfo? lastPartial;
    for (var i = 0; i < delaysMs.length; i++) {
      if (delaysMs[i] > 0) {
        await Future<void>.delayed(Duration(milliseconds: delaysMs[i]));
      }
      try {
        final cloud = await _apiClient.getDistanceInfo(
          coupleId: coupleId,
          currentUserId: currentUserId,
        );
        final mapped = _distanceInfoFromCloud(cloud);
        if (mapped != null) {
          if (mapped.distanceText != null &&
              mapped.distanceText!.contains('km')) {
            return mapped;
          }
          lastPartial = mapped;
        }
      } catch (_) {
        continue;
      }
    }
    return lastPartial;
  }

  DistanceInfo? _distanceInfoFromCloud(Map<String, dynamic> cloud) {
    final kmRaw = cloud['distanceKm'];
    final km = kmRaw is num ? kmRaw.toDouble() : double.tryParse('$kmRaw');
    final me = cloud['me'] as Map<String, dynamic>?;
    final partner = cloud['partner'] as Map<String, dynamic>?;
    final latLng = DistanceInfo(
      isEnabled: true,
      distanceText: null,
      myLatitude: _toDouble(me?['latitude']),
      myLongitude: _toDouble(me?['longitude']),
      partnerLatitude: _toDouble(partner?['latitude']),
      partnerLongitude: _toDouble(partner?['longitude']),
      myLocationVisible: me?['isVisible'] != false,
      partnerLocationVisible: partner?['isVisible'] != false,
      myLocationLabel: (me?['label'] as String?)?.trim(),
      partnerLocationLabel: (partner?['label'] as String?)?.trim(),
    );
    if (km == null) {
      return DistanceInfo(
        isEnabled: true,
        distanceText: partner?['isVisible'] == false ? '对方已隐藏定位' : '等待对方开启定位',
        myLatitude: latLng.myLatitude,
        myLongitude: latLng.myLongitude,
        partnerLatitude: latLng.partnerLatitude,
        partnerLongitude: latLng.partnerLongitude,
        myLocationVisible: latLng.myLocationVisible,
        partnerLocationVisible: latLng.partnerLocationVisible,
        myLocationLabel: latLng.myLocationLabel,
        partnerLocationLabel: latLng.partnerLocationLabel,
      );
    }
    return DistanceInfo(
      isEnabled: true,
      distanceText: '${km.toStringAsFixed(1)} km',
      myLatitude: latLng.myLatitude,
      myLongitude: latLng.myLongitude,
      partnerLatitude: latLng.partnerLatitude,
      partnerLongitude: latLng.partnerLongitude,
      myLocationVisible: latLng.myLocationVisible,
      partnerLocationVisible: latLng.partnerLocationVisible,
      myLocationLabel: latLng.myLocationLabel,
      partnerLocationLabel: latLng.partnerLocationLabel,
    );
  }

  @override
  Future<DistanceInfo> enableDistance() async {
    await _dataSource.enableDistance();
    return getDistanceInfo();
  }

  @override
  Future<DistanceInfo> disableDistance() {
    return _dataSource.disableDistance();
  }

  @override
  Future<DistanceInfo> updateDistanceText(String distanceText) {
    return _dataSource.updateDistanceText(distanceText);
  }

  @override
  Future<DistanceInfo> setMyLocationVisible(bool isVisible) async {
    final identity = await _dataSource.loadIdentityContext();
    final userId = identity.$1;
    final coupleId = identity.$2;
    if (userId == null || coupleId == null) {
      return _dataSource.getDistanceInfo();
    }
    try {
      await _apiClient.setDistanceVisibility(
        coupleId: coupleId,
        currentUserId: userId,
        isVisible: isVisible,
      );
    } catch (_) {
      // keep local behavior even when cloud fails
    }
    return getDistanceInfo();
  }

  double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }
}
