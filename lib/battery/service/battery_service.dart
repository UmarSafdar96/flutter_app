// lib/services/battery_service.dart
import 'package:flutter/services.dart';

class BatteryService {
  static const _platform = MethodChannel('battery/info');

  Future<int?> getBatteryLevel() async {
    try {
      final int result = await _platform.invokeMethod('getBatteryLevel');
      return result;
    } catch (_) {
      return null;
    }
  }
}
