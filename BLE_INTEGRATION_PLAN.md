# BLE Module Integration Plan

## 📋 Overview
Integrate Bluetooth Low Energy (BLE) module to connect to GeyserSwitch hardware firmware. Implements "Local Mode" (BLE-based) as alternative to "Remote Mode" (Firebase-based). The two modes are mutually exclusive - only one active at a time. Optimized for background operation including terminated app state for max temperature notifications.

---

## 🎯 Data Communication

### App → GeyserSwitch Hardware (CONTROLS):
1. **Toggle Geyser State** (bool): Turn geyser on/off
2. **Max Temperature** (double): Set maximum temperature setting
3. **Timer States** (5 booleans): `04:00`, `06:00`, `08:00`, `16:00`, `18:00` - Enable/disable timers
4. **Custom Timer** (String): Custom time value + enabled state

### GeyserSwitch Hardware → App (RECEIVED DATA):
1. **Temperature** (double): Current temperature reading (streamed every 10 seconds)
2. **Geyser State** (bool): Current on/off status (confirmed state from hardware)
3. **Max Temperature Reached** (bool/notification): Alert when max temp threshold reached
4. **Device Status**: Connection status, hardware status

**Note**: Temperature updates are streamed from device every 10 seconds automatically. Max temp notifications are pushed immediately when threshold is reached.

---

## 🏗️ Proposed Architecture

Following clean architecture pattern (similar to home module):

```
ble/
├── data/
│   ├── datasources/
│   │   ├── ble_remote_data_source.dart (abstract)
│   │   └── ble_remote_data_source_impl.dart (flutter_blue_plus)
│   ├── models/
│   │   ├── ble_device_model.dart
│   │   ├── ble_command_model.dart (commands to send)
│   │   └── ble_data_packet_model.dart (data received)
│   └── repos/
│       └── ble_repo_impl.dart
├── domain/
│   ├── entities/
│   │   ├── ble_device_entity.dart
│   │   └── ble_data_packet_entity.dart
│   ├── repos/
│   │   └── ble_repo.dart
│   └── usecases/
│       ├── connect_to_device.dart
│       ├── disconnect_device.dart
│       ├── send_toggle_command.dart
│       ├── send_max_temp_command.dart
│       ├── send_timer_command.dart
│       └── listen_to_temperature_stream.dart
└── presentation/
    ├── providers/
    │   ├── ble_provider.dart (BLE connection state)
    │   └── mode_provider.dart (Local/Remote mode management)
    ├── services/
    │   ├── ble_background_service.dart
    │   ├── ble_connection_manager.dart
    │   ├── ble_sync_service.dart (Local Mode data sync)
    │   └── ble_notification_service.dart
    └── widgets/
        ├── ble_connection_status.dart
        └── mode_selector_widget.dart
```

---

## 📦 Required Dependencies

```yaml
dependencies:
  flutter_blue_plus: ^1.27.0  # Main BLE library
  flutter_background_service: ^5.0.5  # Background service (Android)
  workmanager: ^0.5.2  # Background tasks (both platforms)
  # or
  # flutter_foreground_task: ^7.4.3  # Alternative background solution
```

---

## 🔌 BLE GATT Service Design

### Service UUID: `0000ff00-0000-1000-8000-00805f9b34fb` (Custom)

#### Characteristics:

1. **Geyser Data Stream** (Write/Notify)
   - UUID: `0000ff01-0000-1000-8000-00805f9b34fb`
   - Direction: App → Device
   - Data Format: JSON or Binary Protocol (optimized)
   - Update: On any geyser state change and temperature change

2. **Timer Data Stream** (Write)
   - UUID: `0000ff02-0000-1000-8000-00805f9b34fb`
   - Direction: App → Device
   - Data Format: Binary/JSON
   - Update: On timer state change (when user toggles timers)

3. **Temperature Stream** (Notify)
   - UUID: `0000ff03-0000-1000-8000-00805f9b34fb`
   - Direction: Device → App
   - Data Format: Binary/JSON
   - Update: Every 10 seconds automatically from hardware
   - Purpose: Stream current temperature readings

4. **Max Temperature Alert** (Notify)
   - UUID: `0000ff04-0000-1000-8000-00805f9b34fb`
   - Direction: Device → App
   - Data Format: Binary/JSON
   - Update: Immediate when max temp threshold reached
   - Purpose: Trigger notification even in terminated app state

5. **Connection Heartbeat** (Notify)
   - UUID: `0000ff05-0000-1000-8000-00805f9b34fb`
   - Direction: Device → App
   - Purpose: Keep connection alive, detect disconnections

---

## 📊 Data Protocol Design

### Option 1: JSON (Human-readable, larger payload)
```json
{
  "geysers": [
    {
      "id": "geyser_1",
      "name": "Main Geyser",
      "isOn": true,
      "temperature": 45.5,
      "maxTemp": 55.0
    }
  ],
  "timers": {
    "04:00": true,
    "06:00": false,
    "08:00": true,
    "16:00": false,
    "18:00": true,
    "custom": {
      "enabled": true,
      "time": "14:30"
    }
  }
}
```

### Option 2: Binary Protocol (Optimized, smaller payload)
```
[Header: 1 byte] [Payload: N bytes]

Header Types (App → Device):
- 0x01: Toggle Geyser State (bool: 1 byte)
- 0x02: Set Max Temperature (double: 4 bytes)
- 0x03: Timer Update (single timer: [time: 2 bytes] [state: 1 byte])
- 0x04: Full Timer State (all timers: 5 bytes for 5 timers + 1 byte custom enabled + 2 bytes custom time)
- 0x05: Custom Timer Update ([enabled: 1 byte] [time: 2 bytes HH:MM])

Header Types (Device → App):
- 0x81: Temperature Update (double: 4 bytes, sent every 10s)
- 0x82: Geyser State Confirmation (bool: 1 byte)
- 0x83: Max Temp Alert (trigger: 1 byte boolean)
- 0x84: Device Status ([status: 1 byte])
- 0xFF: Heartbeat (empty payload)

Example payload (Toggle):
[0x01] [0x01] (toggle ON)
[0x01] [0x00] (toggle OFF)

Example payload (Temperature from device):
[0x81] [45.5 as 4-byte float]
```

**Recommendation**: Start with JSON for development/validation, switch to binary protocol for production (more efficient for 10-second updates).

---

## 🔄 Data Flow Architecture

### Remote Mode (Current - Firebase):
```
User Action → Provider → Firebase → Listener → UI Update
                          ↓
                    Firebase Sync → Other Devices/Cloud
```

### Local Mode (New - BLE):
```
User Action → Provider → BLE Service → GeyserSwitch Hardware
                          ↓
                    Hardware processes control
                          
GeyserSwitch Hardware → BLE Service → Provider → UI Update
                          ↓
                    Temperature (every 10s)
                    State confirmations
                    Max temp alerts (immediate)
```

### Mode Switching:
- User selects "Local Mode" or "Remote Mode" in settings
- Only one mode active at a time
- Switching modes:
  - Disconnect from current mode (Firebase listeners or BLE connection)
  - Connect to new mode
  - Sync initial state from new mode

---

## 🎯 Implementation Phases

### Phase 1: Core BLE Infrastructure
**Estimated: 8-12 hours**

1. **Setup BLE Package**
   - Add `flutter_blue_plus` dependency
   - Request BLE permissions (Android + iOS)
   - Create BLE service abstraction

2. **Basic Connection**
   - Device discovery
   - Connection handling
   - GATT service/characteristic discovery
   - Connection state management

3. **Data Layer Setup**
   - Create `BleRemoteDataSource` (abstract)
   - Implement with `flutter_blue_plus`
   - Create data models for BLE packets
   - Repository interface

**Deliverables**:
- `ble/data/datasources/ble_remote_data_source.dart`
- `ble/data/datasources/ble_remote_data_source_impl.dart`
- `ble/data/models/ble_data_models.dart`
- `ble/domain/repos/ble_repo.dart`
- `ble/data/repos/ble_repo_impl.dart`

---

### Phase 2: Domain Layer & Use Cases
**Estimated: 4-6 hours**

1. **Domain Entities**
   - `BleDeviceEntity`
   - `BleDataPacketEntity`

2. **Use Cases**
   - `ConnectToDevice`
   - `DisconnectDevice`
   - `SendGeyserDataToDevice`
   - `SendTimerDataToDevice`
   - `ListenToDeviceCommands`

**Deliverables**:
- `ble/domain/entities/*.dart`
- `ble/domain/usecases/*.dart`

---

### Phase 3: Local Mode Integration Service
**Estimated: 12-16 hours**

1. **BLE Sync Service (Local Mode Only)**
   - Service that operates when Local Mode is active
   - Listens to provider changes (GeyserProvider, TimerProvider, CustomTimerProvider)
   - Converts provider data to BLE commands/format
   - Sends control commands to GeyserSwitch hardware
   - Receives temperature/status updates from hardware

2. **Integration Points**:
   - **Local Mode Active**: 
     - Listen to `GeyserProvider` changes → Send toggle/max_temp commands
     - Listen to `TimerProvider` changes → Send timer updates
     - Listen to `CustomTimerProvider` changes → Send custom timer
     - Receive temperature stream → Update `GeyserProvider` (Local Mode only)
     - Receive max temp alert → Trigger notification
   - **Remote Mode Active**: 
     - No BLE communication, all providers use Firebase

3. **Mode Management**
   - `ModeProvider` or settings to track current mode (Local/Remote)
   - Switch between modes gracefully
   - Disconnect from current mode when switching
   - Sync initial state when entering new mode

4. **State Management**
   - `BleProvider` for BLE connection state
   - Queue system for commands (if device disconnected)
   - Connection status indicator

**Deliverables**:
- `ble/presentation/services/ble_sync_service.dart`
- `ble/presentation/providers/ble_provider.dart`
- `core/providers/mode_provider.dart` (or settings service)
- Mode switching logic

---

### Phase 4: Background Operation & Notifications
**Estimated: 14-20 hours**

1. **Android Background Service**
   - Use `flutter_background_service` for persistent connection
   - Keep BLE connection alive even when app terminated
   - Foreground service for ongoing connection
   - Handle max temperature notifications via local notifications
   - Battery optimization exemptions

2. **iOS Background Modes**
   - Enable "Uses Bluetooth LE accessories" background mode
   - Background BLE connection handling
   - Background task extensions for terminated app state
   - Push notifications for max temp alerts (if using notification service)
   - Handle iOS connection restrictions (may need keepalive packets)

3. **Connection Resilience**
   - Auto-reconnect when device comes in range/advertising
   - Exponential backoff: 2s, 4s, 8s, 16s (max 30s)
   - Connection state monitoring
   - Background scanning for device when disconnected

4. **Notification System**
   - Local notifications when max temp reached (even in terminated state)
   - Notification triggered by BLE characteristic notification
   - Deep link to app when notification tapped

**Deliverables**:
- `ble/presentation/services/ble_background_service.dart`
- `ble/presentation/services/ble_connection_manager.dart`
- `ble/presentation/services/ble_notification_service.dart`
- Android/iOS native configuration
- Notification handling integration

---

### Phase 5: Temperature Streaming & Max Temp Notifications
**Estimated: 8-10 hours**

1. **Temperature Stream Reception**
   - Listen to temperature characteristic notifications
   - Receive updates every 10 seconds
   - Parse temperature data (binary or JSON)
   - Update `GeyserProvider` with new temperature (Local Mode only)

2. **Max Temperature Alert Handling**
   - Listen to max temp alert characteristic
   - Trigger local notification immediately when received
   - Notification must work in terminated app state
   - Deep link back to app when notification tapped
   - Visual indicator in app when alert is active

3. **State Synchronization**
   - When switching to Local Mode: Request current state from device
   - When switching to Remote Mode: Sync current state to Firebase
   - Handle state conflicts (what if device and app disagree?)

**Deliverables**:
- Temperature stream handler
- Max temp notification service
- Notification integration (local notifications)
- State sync service

---

### Phase 6: Mode Switching & Optimization
**Estimated: 8-10 hours**

1. **Mode Switching Implementation**
   - Settings UI to switch between Local/Remote mode
   - Graceful disconnection from current mode
   - Connection to new mode
   - State synchronization on switch
   - Visual indicator of current mode

2. **Auto-Reconnection**
   - Background scanning when device not connected
   - Auto-connect when GeyserSwitch hardware is in range/advertising
   - Connection state UI indicator
   - Retry logic with exponential backoff

3. **Error Handling**
   - Connection failures (show user-friendly message)
   - Write failures (retry with queue)
   - Timeout handling (reconnect)
   - BLE unavailable (fallback to Remote mode?)
   - Handle device out of range gracefully

4. **Performance Optimization**
   - Implement binary protocol (if started with JSON)
   - Optimize payload size for 10-second updates
   - Battery optimization (connection intervals)
   - Memory management for background service

**Deliverables**:
- Mode switching UI and logic
- Auto-reconnection service
- Comprehensive error handling
- Optimized data protocol
- Performance metrics

---

## 🔧 Technical Considerations

### Platform-Specific Requirements

#### Android:
- Permissions:
  - `BLUETOOTH`
  - `BLUETOOTH_ADMIN`
  - `BLUETOOTH_SCAN` (Android 12+)
  - `BLUETOOTH_CONNECT` (Android 12+)
  - `ACCESS_FINE_LOCATION` (for BLE scanning)
  - `FOREGROUND_SERVICE` (for background)

- Background Service:
  - Use `flutter_background_service` for persistent connection
  - Or `WorkManager` for periodic sync
  - Handle battery optimization exemptions

#### iOS:
- Background Modes:
  - Enable "Uses Bluetooth LE accessories" in Info.plist
  - Background BLE connection allowed (but limited)
  - Handle connection timeouts (iOS may disconnect after ~30s inactive)

- Permissions:
  - `NSBluetoothAlwaysUsageDescription` (Info.plist)
  - Request at runtime

### Connection Management Strategy

1. **Connection Lifecycle**:
   ```
   Idle → Scanning → Connecting → Connected → Streaming → Disconnected
   ```

2. **Reconnection Logic**:
   - On disconnect: Wait 2 seconds → Retry connection
   - Exponential backoff: 2s, 4s, 8s, 16s (max 30s)
   - Stop retrying after 5 failed attempts
   - Notify user if persistent failure

3. **Heartbeat Mechanism**:
   - Send ping every 30 seconds
   - If no response in 60s → Consider disconnected
   - Trigger reconnection

### Data Update Strategy

1. **App → Device (Controls)**:
   - **Immediate**: Geyser toggle, max temp change, timer toggle
   - Send immediately when user action occurs
   - No debouncing for controls (user expects immediate response)

2. **Device → App (Received Data)**:
   - **Temperature**: Streamed every 10 seconds automatically from hardware
   - **Max Temp Alert**: Immediate notification when threshold reached
   - **State Confirmations**: Sent after device processes control command

3. **Queue System**:
   - If device disconnected: Queue pending commands
   - When reconnected: Send queued commands in order
   - Max queue size: 10 commands (prevent memory issues)

4. **Update Frequency**:
   - Temperature: Every 10 seconds (hardware-controlled)
   - Controls: Immediately on user action
   - Heartbeat: Every 30 seconds (keep connection alive)

### Connection Optimization

1. **Update Frequency**:
   - **Temperature**: Every 10 seconds (hardware-controlled, cannot be changed)
   - **Controls**: Immediately on user action
   - **Heartbeat**: Every 30 seconds (to keep connection alive, especially iOS)
   - **State Sync**: On mode switch only

2. **Connection Optimization**:
   - Device is grid-powered (no battery concerns on device side)
   - App side: Optimize connection intervals if possible
   - iOS: Send keepalive packets every 30s to prevent timeout
   - Android: Use foreground service for persistent connection
   - Background: Keep connection alive for notifications

3. **Auto-Reconnection**:
   - Scan for device every 10 seconds when disconnected
   - Auto-connect when device found in range
   - Exponential backoff if connection fails repeatedly

---

## 📝 Additional Questions (Optional Clarification)

### Still Need Confirmation:
1. **Geyser Count**: Does one GeyserSwitch BLE device control one geyser, or can it control multiple geysers? (affects data structure)
2. **Device Identification**: How do we identify the correct GeyserSwitch device to connect to? (Device name, MAC address, Service UUID?)
3. **Firmware Coordination**: Do we need to coordinate service/characteristic UUIDs with firmware team, or are they already defined?
4. **Initial State**: When switching to Local Mode, should we request current state from device, or assume app state is authoritative?

---

## 🚨 Implementation Readiness Checklist

### ✅ Device Specifications - ANSWERED
- **Device**: GeyserSwitch hardware module with custom firmware
- **Power**: Grid-powered (no battery concerns)
- **BLE**: Custom firmware with BLE capability
- **Connection**: 1 device, but device can connect to multiple clients
- **Service UUIDs**: Need to be defined/coordinated with firmware team

### ✅ Platform Priority - ANSWERED
- **Platforms**: Both iOS and Android
- **Background**: Must work in all 3 states (foreground, background, terminated)
- **Critical**: Max temp notifications must work when app is terminated
- **iOS**: Will need background task extensions or keepalive packets to maintain connection

### ✅ Background Requirements - ANSWERED
- **All 3 states required**: Foreground, background, and terminated app state
- **Purpose**: Max temperature notifications must reach user even when app closed
- **Android**: Foreground service required for terminated state
- **iOS**: Background mode "Uses Bluetooth LE accessories" + keepalive packets

### ✅ Data Volume - ANSWERED
- **Temperature Updates**: Every 10 seconds (hardware-controlled, fixed frequency)
- **Control Updates**: Immediately on user action (toggle, max temp, timers)
- **Max Temp Alert**: Immediate push notification when threshold reached
- **Multiple Geysers**: Need clarification - does one BLE device control multiple geysers, or one device per geyser?

### ✅ Connection Management - ANSWERED
- **Connection Type**: Auto-reconnect when device in range/advertising
- **Pairing**: Auto-connect (no manual pairing needed)
- **Device Count**: 1 device connection per app instance
- **Device Capability**: GeyserSwitch hardware can connect to multiple clients simultaneously
- **Reconnection**: Auto-reconnect with exponential backoff when device comes in range

### ✅ Command Protocol - ANSWERED
- **App → Device Controls**: Toggle geyser, Set max temp, Timer toggles (5 timers), Custom timer
- **Device → App Data**: Temperature (every 10s), Geyser state confirmations, Max temp alerts, Connection status
- **Control Authority**: App controls geyser (device receives commands and executes)
- **Two-Way**: Device sends status/confirmations back to app

### ✅ Error Handling Priority - ANSWERED
- **Mode Exclusivity**: Local Mode (BLE) and Remote Mode (Firebase) are separate
- **Mode Switching**: If BLE fails in Local Mode, user can switch to Remote Mode
- **Disconnection Handling**: Show user-friendly message, attempt auto-reconnect
- **Fallback**: No automatic fallback - user chooses which mode to use
- **Notification**: Show connection status indicator, notify on persistent disconnection

---

## 📝 Recommended Implementation Order

### Immediate Next Steps (After Answers):

1. **Research Phase** (2-4 hours)
   - Identify exact BLE device model
   - Test device connectivity with BLE scanner app
   - Document device's existing GATT services
   - Determine if firmware modification needed

2. **Proof of Concept** (4-6 hours)
   - Simple app that connects to device
   - Send test data packet
   - Receive acknowledgment
   - Verify background capability

3. **Phase 1 Implementation** (Start here once POC works)

---

## 🎯 Success Criteria

- ✅ GeyserSwitch hardware receives control commands (toggle, max temp, timers) immediately
- ✅ App receives temperature updates every 10 seconds from hardware
- ✅ Max temperature notifications work in all app states (foreground, background, terminated)
- ✅ Connection maintained in background and terminated states (for notifications)
- ✅ Auto-reconnect when device comes in range/advertising
- ✅ Two-way communication functional (app controls → device, device data → app)
- ✅ Mode switching works smoothly (Local ↔ Remote)
- ✅ Error handling doesn't crash app
- ✅ Graceful handling of device out of range
- ✅ Optimized data transfer (10-second temperature updates handled efficiently)

---

## ⚠️ Potential Challenges

1. **iOS Background Limitations**
   - iOS may disconnect BLE after ~30 seconds of inactivity
   - **Solution**: Send heartbeat packets every 30 seconds to keep connection alive
   - Background task extensions for terminated app state

2. **Terminated App State Notifications**
   - Android: Foreground service required (notification must be shown)
   - iOS: Background task extensions may have limitations
   - **Solution**: Use local notifications triggered by BLE characteristic notifications

3. **Connection Stability**
   - BLE connections can be flaky (range, interference)
   - **Solution**: Robust auto-reconnection with exponential backoff, scan for device when disconnected
   - Since device is grid-powered, device should maintain connection better

4. **Mode Switching State Sync**
   - Need to sync state when switching from Remote to Local mode
   - **Solution**: Request current state from device on Local Mode connection
   - Update providers with device state, merge with app state if conflicts

5. **10-Second Update Frequency**
   - Continuous updates can impact battery (on app side)
   - **Solution**: Optimize data payload size (binary protocol), efficient parsing
   - Since device is grid-powered, device side is fine

6. **Background Service Requirements**
   - Android: Foreground service with persistent notification (required for terminated state)
   - iOS: Background mode restrictions
   - **Solution**: Minimize notification impact, allow user to minimize/dismiss

---

## 📚 Recommended Resources

- `flutter_blue_plus` documentation
- BLE GATT specification
- Platform-specific BLE guides (Android/iOS)
- Background task implementation guides

---

## 📋 Updated Implementation Summary

### Key Changes Based on Requirements:
1. ✅ **Device Type**: GeyserSwitch hardware firmware (not earphones)
2. ✅ **Mode Exclusivity**: Local Mode (BLE) and Remote Mode (Firebase) are mutually exclusive
3. ✅ **Controls**: App controls device (toggle, max temp, timers)
4. ✅ **Data Reception**: Device streams temperature (10s) and sends alerts (immediate)
5. ✅ **Background**: Must work in terminated state for max temp notifications
6. ✅ **Connection**: Auto-reconnect, 1 device, device can handle multiple clients

### Revised Time Estimates:
- **Phase 1**: 8-12 hours (Core BLE Infrastructure)
- **Phase 2**: 4-6 hours (Domain Layer)
- **Phase 3**: 12-16 hours (Local Mode Integration) ⬆️ Increased
- **Phase 4**: 14-20 hours (Background + Notifications) ⬆️ Increased
- **Phase 5**: 8-10 hours (Temperature Streaming + Alerts) ⬆️ Increased
- **Phase 6**: 8-10 hours (Mode Switching + Optimization) ⬆️ Increased

**Total Estimated**: ~54-74 hours (6.75-9.25 days of focused work)

### Critical Integration Points:

**Provider Modifications Needed**:
- `GeyserProvider`: Needs to support both Firebase (Remote) and BLE (Local) modes
  - Inject mode provider to determine which data source to use
  - Abstract data source access (Firebase vs BLE)
  - Temperature updates come from different sources depending on mode
  
- `TimerProvider` & `CustomTimerProvider`: Similar dual-mode support
  - Firebase updates in Remote Mode
  - BLE commands in Local Mode

**Architecture Pattern**:
- Use Strategy Pattern or Dependency Injection for data source selection
- Providers become mode-aware and route to appropriate data source
- Keep providers as single source of truth for UI layer

### Next Steps:
1. **Confirm remaining questions** (if any)
2. **Coordinate with firmware team** on service UUIDs and protocol
3. **Test device connectivity** with BLE scanner app
4. **Begin Phase 1** implementation

Ready to start Phase 1 once service UUIDs are confirmed! 🚀

