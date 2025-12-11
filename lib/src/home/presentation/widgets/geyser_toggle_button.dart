import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/home/presentation/providers/geyser_provider.dart';

class GeyserToggleButton extends StatefulWidget {
  final GeyserEntity geyser;
  const GeyserToggleButton({Key? key, required this.geyser}) : super(key: key);

  @override
  State<GeyserToggleButton> createState() => _GeyserToggleButtonState();
}

class _GeyserToggleButtonState extends State<GeyserToggleButton> {
  bool _busy = false;

  void _showSnack(BuildContext context, String message, {Color? bg}) {
    final bar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    );
    // Don’t fully remove first; replace/hide is smoother
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }

  @override
  Widget build(BuildContext context) {
    // If a Provider<GeyserEntity> exists, Consumer is fine. Otherwise drop it.
    return Consumer<GeyserEntity>(
      builder: (_, geyser, __) {
        return Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _busy ? null : () async {
              _busy = true;
              final previousState = geyser.isOn;
              try {
                await context.read<GeyserProvider>().toggleGeyser(geyser);
                if (!mounted) return;
                final msg = previousState
                    ? '${geyser.name} has been turned OFF successfully'
                    : '${geyser.name} has been turned ON successfully';
                _showSnack(context, msg, bg: Colours.secondaryColour);
              } catch (_) {
                if (!mounted) return;
                _showSnack(context,
                  'Failed to toggle ${geyser.name}. Please try again.',
                  bg: Colors.red,
                );
              } finally {
                if (mounted) _busy = false;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: geyser.isOn
                    ? Colours.primaryOrange.withValues(alpha:.5)
                    : Colours.secondaryColour,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: geyser.isOn
                        ? Colours.primaryOrange.withValues(alpha:.2)
                        : Colors.grey.shade400.withValues(alpha:0.3),
                    spreadRadius: 2,
                    blurRadius: geyser.isOn ? 10 : 3,
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: geyser.isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
