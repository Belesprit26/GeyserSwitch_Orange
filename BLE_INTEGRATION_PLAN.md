# BLE Module Integration Plan (Revised)

## 📋 Overview
Add a Bluetooth Low Energy (BLE) “Local Mode” that works alongside existing Firebase “Remote Mode”. Only one mode is active at a time, and switching is seamless. The BLE path prioritizes reliability, background delivery of safety alerts (max temperature), and simple password-based access control.

Non-goals: enterprise-grade cryptography or multi-device mesh. We keep security light with a password gate and recommend OS-level pairing for link encryption.

---

## 🎯 Objectives
- Local Mode over BLE with low-latency control and 10-second temperature updates
- Alerts/notifications delivered in background and (platform-permitting) terminated states
- Single source of truth at the UI layer via existing providers
- Clean mode switching: Local (BLE) ↔ Remote (Firebase)

---

## 🏗️ Architecture

```
lib/src/ble/
├── data/
│   ├── datasources/
│   │   ├── ble_remote_data_source.dart              # abstract
│   │   └── ble_remote_data_source_impl.dart         # flutter_blue_plus
│   ├── models/
│   │   ├── ble_device_model.dart
│   │   ├── ble_command_model.dart
│   │   └── ble_frame_model.dart
│   └── repos/
│       └── ble_repo_impl.dart
├── domain/
│   ├── entities/
│   │   ├── ble_device_entity.dart
│   │   └── ble_frame_entity.dart
│   ├── repos/
│   │   └── ble_repo.dart
│   └── usecases/
│       ├── connect_to_device.dart
│       ├── disconnect_device.dart
│       ├── authenticate_with_password.dart
│       ├── send_toggle_command.dart
│       ├── send_max_temp_command.dart
│       ├── send_timers_command.dart
│       └── listen_temperature_stream.dart
└── presentation/
    ├── providers/
    │   ├── ble_provider.dart          # connection + auth state
    │   └── mode_provider.dart         # Local(BLE) | Remote(Firebase)
    ├── services/
    │   ├── ble_connection_manager.dart
    │   ├── ble_sync_service.dart      # bridges providers <-> BLE
    │   └── ble_notification_service.dart
    └── widgets/
        ├── ble_connection_status.dart
        └── mode_selector_widget.dart
```

Integration with current code:
- `GeyserProvider` (and timer providers) remain UI single source of truth.
- A `ModeProvider` routes operations to Firebase or BLE via a Strategy pattern.
- In Local Mode, `BleSyncService` listens to provider changes (toggle/max temp/timers) and writes to BLE, and applies device updates to providers.

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_blue_plus: ^1.27.0
  flutter_local_notifications: ^17.2.0
  permission_handler: ^11.3.1

  # Android background (persistent connection + notifications)
  flutter_background_service: ^5.0.5
```

Notes:
- Android: Foreground service keeps BLE active in background; user sees a persistent notification.
- iOS: Use Bluetooth background mode and CoreBluetooth state restoration (plugin-backed). Alerts rely on characteristic notifications waking the app when possible.

---

## 🔌 BLE GATT Design

Service UUID (custom): `0000ff00-0000-1000-8000-00805f9b34fb`

Characteristics:
1) control (WriteWithResponse) — App → Device
   - UUID: `0000ff01-0000-1000-8000-00805f9b34fb`
   - Purpose: Send commands (auth, toggle, max temp, timers, get state)

2) status (Notify) — Device → App
   - UUID: `0000ff02-0000-1000-8000-00805f9b34fb`
   - Purpose: Command acks, errors, state confirmations

3) temperature (Notify) — Device → App
   - UUID: `0000ff03-0000-1000-8000-00805f9b34fb`
   - Purpose: Periodic temperature updates (~10s)

4) alert (Notify) — Device → App
   - UUID: `0000ff04-0000-1000-8000-00805f9b34fb`
   - Purpose: Immediate max-temperature alerts

5) heartbeat (Notify) — Device → App
   - UUID: `0000ff05-0000-1000-8000-00805f9b34fb`
   - Purpose: Liveness signal (e.g., every 30s)

Rationale:
- Single write characteristic simplifies command flow and reliability (WriteWithResponse ensures delivery/ack path via `status`).
- All device-originating data use Notify to minimize overhead and wake the app when possible.

---

## 📊 Binary Protocol (compact, BLE-friendly)

General framing (little-endian):
```
[CMD (1)] [SEQ (1)] [LEN (1)] [PAYLOAD (LEN)]
```

Types:
- bool: 1 byte (0x00/0x01)
- float32: 4 bytes (IEEE-754 LE)
- uint16: 2 bytes (LE)
- time minutes: uint16 minutes-since-midnight (0–1439)

Commands (App → Device) via `control`:
- 0x10 AUTH
  - payload: [passwordLen (1)] [password (N bytes ASCII)]
- 0x01 TOGGLE
  - payload: [newState (1)]  # 0x00=OFF, 0x01=ON
- 0x02 SET_MAX_TEMP
  - payload: [tempFloat32 (4)]
- 0x03 SET_TIMERS
  - payload: [mask (1)] [customEnabled (1)] [customTimeMin (2)]
    - mask bit order: 0:04:00, 1:06:00, 2:08:00, 3:16:00, 4:18:00
- 0x20 GET_STATE
  - payload: empty (device responds with status snapshot)

Device → App frames:
- 0x80 ACK
  - payload: [cmdEcho (1)] [result (1)] [optErrorCode (1 optional)]
- 0x81 TEMPERATURE
  - payload: [tempFloat32 (4)]
- 0x82 STATE
  - payload: [isOn (1)] [maxTempFloat32 (4)] [mask (1)] [customEnabled (1)] [customTimeMin (2)]
- 0x83 ALERT_MAX_TEMP
  - payload: [isTriggered (1)] [tempFloat32 (4)]
- 0xFF HEARTBEAT
  - payload: empty

MTU/Fragmentation:
- Payloads fit within common 20–185 byte MTUs. No fragmentation needed for defined frames.

Security (light):
- App sends AUTH on connect with a shared password; device rejects controls until AUTH succeeds.
- Strongly recommended: enable pairing/bonding so the link is encrypted by the OS (minimal UX friction, better than plaintext).

---

## 🔄 Data Flow & Mode Switching

Remote Mode (existing):
```
User → Providers → Firebase → Listeners → UI
```

Local Mode (new):
```
User → Providers → BleSyncService → Device
Device → BleSyncService → Providers → UI
```

Mode switching (single source of truth = Providers):
1) Switching to Local Mode
   - Detach Firebase listeners
   - Connect BLE → discover service → subscribe (status/temperature/alert/heartbeat)
   - Send AUTH → send GET_STATE → seed providers
   - Start mirroring provider changes to BLE

2) Switching to Remote Mode
   - Unsubscribe & disconnect BLE
   - Attach Firebase listeners → seed providers from cloud

Optional shadow sync:
- While in Local Mode, optionally write state to Firebase so other devices remain up-to-date. Default: off (conserves writes and avoids conflicts).

---

## 📱 Background & Terminated Behavior

Android:
- Foreground service via `flutter_background_service` keeps connection alive with a persistent notification.
- Receive `alert` notifications in background and surface local notifications immediately.
- If user force-stops the app, the service cannot restart automatically (OS rule).

iOS:
- Enable “Uses Bluetooth LE accessories” in Info.plist.
- Rely on CoreBluetooth background execution and state restoration; the OS may relaunch the app when notifications arrive from a subscribed characteristic.
- Alerts are delivered best-effort in background. If the app is force-quit by the user, iOS may not relaunch until the user opens the app again.

Notification delivery:
- `alert` characteristic triggers a local notification with current temperature and deep link.
- Provide user settings to opt-in/out of BLE-based alerts.

---

## 🔁 Connection Management
- Lifecycle: Idle → Scanning → Connecting → Discovering → Subscribing → Connected → Disconnected
- Reconnect strategy: exponential backoff (2s, 4s, 8s, 16s, cap 30s; retry ≤ 5 then pause)
- Known device selection: store device ID after first connect; filter scans by service UUID to reduce noise
- Heartbeat: device notifies every ~30s; if missed for 60s, consider disconnected and reconnect

---

## 🔐 Security & Provisioning (light)
- Password: short ASCII string provisioned during onboarding (e.g., via Wi‑Fi provisioning already in app)
- App AUTH on connect; device rejects controls until authenticated
- Recommend OS pairing/bonding for link encryption with minimal UX
- Ownership transfer: reset password via physical action (e.g., long-press button) if needed

---

## 🔧 Integration with Existing Providers

ModeProvider:
- Enum: Local | Remote
- Persists last choice; exposes setters that orchestrate switch sequences

GeyserProvider:
- Introduce `GeyserDataSource` interface with two impls: FirebaseDataSource, BleDataSource
- On Local Mode: read/write via BLE; on Remote Mode: Firebase
- Toggle/max temp UI remain unchanged

Timer providers:
- Mirror the same pattern (BLE for Local, Firebase for Remote)

BleSyncService:
- Subscribes to provider changes and emits BLE commands
- Applies device notifications back to providers
- Queues commands if temporarily disconnected and flushes on reconnect

---

## 📜 Permissions & Platform Config

Android Manifest:
- BLUETOOTH, BLUETOOTH_ADMIN (pre-12)
- BLUETOOTH_SCAN, BLUETOOTH_CONNECT (12+)
- ACCESS_FINE_LOCATION (for scanning on older APIs)
- FOREGROUND_SERVICE (+ service type)
- POST_NOTIFICATIONS (13+)

iOS Info.plist:
- NSBluetoothAlwaysUsageDescription
- UIBackgroundModes: bluetooth-central

Runtime:
- Use `permission_handler` to request Bluetooth, Location (legacy), and Notifications.

---

## 🚀 Implementation Phases

Phase 1 — Core BLE (8–12h)
- Add deps, permissions, service skeleton
- Scan/connect/discover/subscribe; WriteWithResponse to control; Notify handlers

Deliverables:
- data/datasources/*, data/models/*, domain/repos/*, data/repos/*

Phase 2 — Domain & Use Cases (4–6h)
- Entities and use cases (connect/disconnect/auth/toggle/max temp/timers/listen temperature)

Phase 3 — Local Mode Integration (10–14h)
- ModeProvider, BleSyncService, wiring into existing providers, GET_STATE seeding, queueing

Phase 4 — Background & Notifications (12–18h)
- Android foreground service, iOS background mode, local notifications from `alert`

Phase 5 — Robustness & UX (6–8h)
- Reconnect/backoff, known-device selection UI, error states, indicators

---

## ✅ Success Criteria
- Controls respond instantly in Local Mode; WriteWithResponse acks via `status`
- Temperature updates ~every 10s via `temperature`
- Alerts surface as local notifications in background; best-effort on iOS terminated
- Seamless mode switching without duplicate updates or memory leaks
- Stable reconnection behavior and low crash rate

---

## ❓ Open Questions
1) Single vs multiple geysers per device? (Current plan assumes a single controlled geyser)
2) Confirm device supports one active central (recommended) or multiple centrals
3) Confirm password provisioning flow (re-use existing onboarding?)
4) Shadow sync to Firebase while in Local Mode: on/off?

---

## 🔄 Change Log (what changed and why)
- Consolidated GATT to: control (WriteWithResponse), status/temperature/alert/heartbeat (Notify) to remove direction conflicts and ensure reliable acks
- Switched protocol to explicit binary with sizes/endianness for BLE efficiency; defined timer bitmask and minutes-encoding
- Added lightweight AUTH command for password protection; recommended OS pairing for simple link encryption
- Clarified Android foreground service and iOS background/restore realities to meet background/terminated alert goals
- Introduced Strategy pattern in providers for clean Local/Remote routing and seamless mode switching
- Added reconnection/heartbeat strategy and known-device selection to improve UX stability
- Tightened implementation phases and success criteria around alerts and mode switching


