import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';

class ModeIndicator extends StatelessWidget {
  const ModeIndicator({super.key});

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
            ),
            const SizedBox(width: 8),
            _Segment(
              label: 'Remote',
              active: !isLocal,
              activeColor: Colors.green,
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

  const _Segment({
    required this.label,
    required this.active,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
    );
  }
}


