import 'dart:async';
import 'dart:typed_data';

import 'package:gs_orange/src/ble/data/datasources/ble_remote_data_source.dart';
import 'package:gs_orange/src/ble/data/models/ble_command_model.dart';
import 'package:gs_orange/src/ble/data/models/ble_frame_model.dart';
import 'package:gs_orange/src/ble/domain/events/ble_events.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';

class BleRepoImpl implements BleRepo {
  final BleRemoteDataSource dataSource;

  BleRepoImpl({required this.dataSource}) {
    _wireStreams();
  }

  int _seq = 0;

  late final Stream<bool> _connected$ = dataSource.connected$.asBroadcastStream();

  late final StreamController<BleAck> _ackCtrl = StreamController<BleAck>.broadcast();
  late final StreamController<BleState> _stateCtrl = StreamController<BleState>.broadcast();
  late final StreamController<BleTemperature> _tempCtrl = StreamController<BleTemperature>.broadcast();
  late final StreamController<BleAlert> _alertCtrl = StreamController<BleAlert>.broadcast();
  late final StreamController<BleHeartbeat> _hbCtrl = StreamController<BleHeartbeat>.broadcast();

  StreamSubscription<Uint8List>? _statusSub;
  StreamSubscription<Uint8List>? _tempSub;
  StreamSubscription<Uint8List>? _alertSub;
  StreamSubscription<DateTime>? _hbSub;

  void _wireStreams() {
    _statusSub = dataSource.status$.listen((raw) {
      final frame = BleFrameDecoder.tryDecode(raw);
      if (frame == null) return;
      switch (frame.cmd) {
        case BleCmd.ack:
          if (frame.payload.isEmpty) return;
          final cmdEcho = frame.payload[0];
          final success = frame.payload.length > 1 ? frame.payload[1] == 0x01 : true;
          final errorCode = frame.payload.length > 2 ? frame.payload[2] : null;
          _ackCtrl.add(BleAck(cmdEcho: cmdEcho, success: success, errorCode: errorCode));
          break;
        case BleCmd.state:
          if (frame.payload.length < 8) return;
          final isOn = frame.payload[0] == 0x01;
          final maxTemp = BlePacking.bytesToFloat32(Uint8List.sublistView(frame.payload, 1, 5));
          final mask = frame.payload[5];
          final customEnabled = frame.payload[6] == 0x01;
          final customMin = BlePacking.bytesToUint16(Uint8List.sublistView(frame.payload, 7, 9));
          _stateCtrl.add(BleState(
            isOn: isOn,
            maxTempC: maxTemp,
            timerMask: mask,
            customEnabled: customEnabled,
            customMinutes: customMin,
          ));
          break;
        default:
          break;
      }
    });

    _tempSub = dataSource.temperature$.listen((raw) {
      final frame = BleFrameDecoder.tryDecode(raw);
      if (frame == null || frame.cmd != BleCmd.temperature) return;
      if (frame.payload.length < 4) return;
      final temp = BlePacking.bytesToFloat32(Uint8List.sublistView(frame.payload, 0, 4));
      _tempCtrl.add(BleTemperature(temp));
    });

    _alertSub = dataSource.alert$.listen((raw) {
      final frame = BleFrameDecoder.tryDecode(raw);
      if (frame == null || frame.cmd != BleCmd.alertMaxTemp) return;
      if (frame.payload.isEmpty) return;
      final trig = frame.payload[0] == 0x01;
      final temp = frame.payload.length >= 5
          ? BlePacking.bytesToFloat32(Uint8List.sublistView(frame.payload, 1, 5))
          : 0.0;
      _alertCtrl.add(BleAlert(triggered: trig, tempC: temp));
    });

    _hbSub = dataSource.heartbeat$.listen((ts) {
      _hbCtrl.add(BleHeartbeat(ts));
    });
  }

  int _nextSeq() {
    _seq = (_seq + 1) & 0xFF;
    return _seq;
  }

  @override
  Stream<bool> get connected$ => _connected$;

  @override
  Stream<BleAck> get ack$ => _ackCtrl.stream;

  @override
  Stream<BleTemperature> get temperature$ => _tempCtrl.stream;

  @override
  Stream<BleState> get state$ => _stateCtrl.stream;

  @override
  Stream<BleAlert> get alert$ => _alertCtrl.stream;

  @override
  Stream<BleHeartbeat> get heartbeat$ => _hbCtrl.stream;

  @override
  Future<void> startScan({required String serviceUuid}) {
    return dataSource.startScan(serviceUuid: serviceUuid);
    
  }

  @override
  Future<void> stopScan() {
    return dataSource.stopScan();
  }

  @override
  Future<void> connect({required String deviceId}) async {
    await dataSource.connect(deviceId: deviceId);
  }

  @override
  Future<void> subscribeToNotifications() {
    return dataSource.subscribeToNotifications();
  }

  @override
  Future<void> disconnect() async {
    await dataSource.disconnect();
  }

  @override
  Future<void> authenticate(String password) async {
    final payload = BleCommandBuilder.authPayload(password);
    final frame = BleCommandBuilder.frame(BleCmd.auth, _nextSeq(), payload);
    await dataSource.writeControl(frame);
  }

  @override
  Future<void> sendToggle(bool on) async {
    final payload = BleCommandBuilder.togglePayload(on);
    final frame = BleCommandBuilder.frame(BleCmd.toggle, _nextSeq(), payload);
    await dataSource.writeControl(frame);
  }

  @override
  Future<void> setMaxTemp(double tempC) async {
    final payload = BleCommandBuilder.setMaxTempPayload(tempC);
    final frame = BleCommandBuilder.frame(BleCmd.setMaxTemp, _nextSeq(), payload);
    await dataSource.writeControl(frame);
  }

  @override
  Future<void> setTimers({required int mask, required bool customEnabled, required int customMinutes}) async {
    final payload = BleCommandBuilder.setTimersPayload(
      mask: mask,
      customEnabled: customEnabled,
      customMinutes: customMinutes,
    );
    final frame = BleCommandBuilder.frame(BleCmd.setTimers, _nextSeq(), payload);
    await dataSource.writeControl(frame);
  }

  @override
  Future<void> requestState() async {
    final frame = BleCommandBuilder.frame(BleCmd.getState, _nextSeq(), const <int>[]);
    await dataSource.writeControl(frame);
  }

  /// Dispose stream subscriptions and controllers.
  void dispose() {
    _statusSub?.cancel();
    _tempSub?.cancel();
    _alertSub?.cancel();
    _hbSub?.cancel();
    _ackCtrl.close();
    _stateCtrl.close();
    _tempCtrl.close();
    _alertCtrl.close();
    _hbCtrl.close();
  }
}


