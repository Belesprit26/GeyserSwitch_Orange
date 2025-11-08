import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/src/ble/domain/events/ble_events.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:gs_orange/src/home/presentation/providers/geyser_provider.dart';

/// Listens to BLE streams and synchronizes them into app providers while
/// Local Mode is active. Keep this lightweight and presentation-friendly.
class BleSyncService {
  BleSyncService({required BleRepo bleRepo}) : _bleRepo = bleRepo;

  final BleRepo _bleRepo;

  StreamSubscription<bool>? _connectedSub;
  StreamSubscription<BleTemperature>? _tempSub;
  StreamSubscription<BleState>? _stateSub;
  StreamSubscription<BleAlert>? _alertSub;
  StreamSubscription<BleHeartbeat>? _hbSub;

  bool _started = false;
  BuildContext? _context;

  /// Begin syncing BLE → Providers. Safe to call multiple times.
  void start(BuildContext context) {
    if (_started) return;
    _started = true;
    _context = context;

    // Only sync while Local Mode is active
    final mode = context.read<ModeProvider>();
    if (!mode.isLocal) {
      _started = false;
      _context = null;
      return;
    }

    _connectedSub = _bleRepo.connected$.listen((isConnected) {
      // Could expose connection state to UI later. For now, no-op.
      // If disconnected, keep service alive (auto-reconnect handled elsewhere).
    });

    _tempSub = _bleRepo.temperature$.listen((evt) {
      final c = _context;
      if (c == null) return;
      final mode = c.read<ModeProvider>();
      if (!mode.isLocal) return;
      final geysers = c.read<GeyserProvider>();
      geysers.updateFromLocal(temperature: evt.tempC);
    });

    _stateSub = _bleRepo.state$.listen((evt) {
      final c = _context;
      if (c == null) return;
      final mode = c.read<ModeProvider>();
      if (!mode.isLocal) return;
      final geysers = c.read<GeyserProvider>();
      geysers.updateFromLocal(isOn: evt.isOn, maxTemp: evt.maxTempC);
    });

    _alertSub = _bleRepo.alert$.listen((evt) {
      // Step 1: Capture event only. In a later step we'll route this to notifications.
      // final c = _context; if (c == null) return;
      // TODO: Hook NotificationService for max-temp alerts.
    });

    _hbSub = _bleRepo.heartbeat$.listen((_) {
      // Heartbeat received - keepalive OK. No-op for now.
    });

    // Request a full state snapshot once syncing is live.
    _bleRepo.requestState();
  }

  /// Stop syncing and tear down subscriptions. Safe to call multiple times.
  Future<void> stop() async {
    await _connectedSub?.cancel();
    await _tempSub?.cancel();
    await _stateSub?.cancel();
    await _alertSub?.cancel();
    await _hbSub?.cancel();
    _connectedSub = null;
    _tempSub = null;
    _stateSub = null;
    _alertSub = null;
    _hbSub = null;
    _started = false;
    _context = null;
  }
}


