import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/ble/presentation/services/ble_sync_service.dart';

class ModeIndicator extends StatefulWidget {
  const ModeIndicator({super.key});

  @override
  State<ModeIndicator> createState() => _ModeIndicatorState();
}

class _ModeIndicatorState extends State<ModeIndicator> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ModeProvider>(
      builder: (_, mode, __) {
        final isLocal = mode.isLocal;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Segment(
              label: 'Local',
              active: isLocal,
              activeColor: Colors.blueAccent,
              onTap: _busy
                  ? null
                  : () async {
                      if (isLocal) return;
                      setState(() => _busy = true);
                      try {
                        final prefs = sl<SharedPreferences>();
                        final lastId = prefs.getString('last_ble_device_id');
                        if (lastId == null || lastId.isEmpty) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No saved device. Open BLE scan to connect.'),
                              ),
                            );
                          }
                          return;
                        }
                        final ble = sl<BleRepo>();
                        await ble.connect(deviceId: lastId);
                        await ble.subscribeToNotifications();
                        sl<BleSyncService>().start(context);
                        if (mounted) {
                          context.read<ModeProvider>().setLocal();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Switched to Local Mode')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to switch to Local: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
            ),
            const SizedBox(width: 8),
            _Segment(
              label: 'Remote',
              active: !isLocal,
              activeColor: Colors.green,
              onTap: _busy
                  ? null
                  : () async {
                      if (!isLocal) return;
                      setState(() => _busy = true);
                      try {
                        // Stop BLE sync and disconnect
                        await sl<BleSyncService>().stop();
                        final ble = sl<BleRepo>();
                        await ble.disconnect();
                        if (mounted) {
                          context.read<ModeProvider>().setRemote();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Switched to Remote Mode')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to switch to Remote: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
            ),
          ],
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  const _Segment({
    required this.label,
    required this.active,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? activeColor : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active ? activeColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}


