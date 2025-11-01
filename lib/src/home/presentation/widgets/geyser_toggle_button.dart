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
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeyserProvider>(context, listen: false);
    // Store the widget's context (from StatefulWidget) to use for snackbar
    // This ensures we have access to the ScaffoldMessenger even after async operations
    final scaffoldContext = context;

    // LISTEN TO GYSER ENTITY CHANGES: Use Consumer to reactively rebuild when geyser state changes
    return Consumer<GeyserEntity>(
      builder: (_, geyser, __) {
        return Center(
          child: GestureDetector(
            onTap: () async {
              // Store previous state for snackbar message
              final previousState = geyser.isOn;
              
              try {
                // Wait for Firebase update to complete
                await provider.toggleGeyser(geyser);
                
                // SNACKBAR AFTER COMPLETION: Show success message only after Firebase confirms
                // Check if widget is still mounted before showing snackbar
                if (!mounted) return;
                
                final message = previousState
                    ? '${geyser.name} has been turned OFF successfully'
                    : '${geyser.name} has been turned ON successfully';
                
                // Use ScaffoldMessenger directly with mounted check
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldContext)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colours.secondaryColour,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                      ),
                    );
                }
              } catch (error) {
                // ERROR HANDLING: Show error message if toggle failed
                // Check if widget is still mounted before showing snackbar
                if (!mounted) return;
                
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldContext)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to toggle ${geyser.name}. Please try again.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                      ),
                    );
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: geyser.isOn
                    ? Colours.primaryOrange.withOpacity(.5)
                    : Colours.secondaryColour,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: geyser.isOn
                        ? Colours.primaryOrange.withOpacity(.2)
                        : Colors.grey.shade400.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: geyser.isOn ? 10 : 3,
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: geyser.isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
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

