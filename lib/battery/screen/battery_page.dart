// lib/ui/battery_page.dart
import 'package:flutter/material.dart';

import '../service/battery_service.dart';
import '../service/biometric_service.dart';

class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  final biometricService = BiometricService();
  final batteryService = BatteryService();

  String _batteryLevel = 'Unknown battery level.';

  Future<void> _loadBatteryLevel() async {
    final isAuthenticated = await biometricService.authenticate();

    if (!isAuthenticated) {
      setState(() {
        _batteryLevel = 'Authentication failed.';
      });
      return;
    }

    final battery = await batteryService.getBatteryLevel();
    setState(() {
      _batteryLevel = battery != null
          ? 'Battery level: $battery%'
          : 'Failed to get battery level.';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBatteryLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Battery Info")),
      body: Center(
        child: Text(
          _batteryLevel,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBatteryLevel,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
