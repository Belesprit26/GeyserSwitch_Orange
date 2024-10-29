import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/core/res/colours.dart';

import '../../../../../../core/utils/core_utils.dart';

class CustomTimer extends StatelessWidget {
  const CustomTimer({super.key});

  // Convert string to TimeOfDay
  TimeOfDay _convertStringToTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Format TimeOfDay to string
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomTimerProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // Main container UI
            Container(
              width: MediaQuery.of(context).size.width * .93,
              height: MediaQuery.of(context).size.height * .07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: provider.isCustom
                    ? LinearGradient(
                  colors: [
                    Colours.primaryOrange.withOpacity(0.99),
                    Colors.blueAccent.withOpacity(0.6),
                    Colors.redAccent.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                    : null, // Apply gradient when custom timer is on
                color: provider.isCustom ? null : Colors.white70, // White70 when off
                border: Border.all(color: Colors.white, width: 1), // Thin white border
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.7),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        // Open the time picker and update custom time
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: provider.customTime == null || provider.customTime!.isEmpty
                              ? TimeOfDay.now()
                              : _convertStringToTimeOfDay(provider.customTime!),
                        );
                        if (picked != null) {
                          final formattedTime = _formatTime(picked);
                          await provider.updateCustomTime(formattedTime);
                        }
                        //Notification tester
                        /*await SendNotificationService.sendNotificationUsingApi(
                            token: 'dtuwPkO5S56LNCJkJHyoGl:APA91bGp4r_zTP0oueU135OzaSPuQfazVTFWHSGFXwZv1GRQv59vVt6dqL0Yr2On61ZUYaMjHLCVvI2hvtMeFFiiSKCobkMh_wLxohHDxHRAr5_mF9dm1knNmIxJs1hSYoyYGmR7aCvy',
                            title: "Checking stuff",
                            body: "This is the official check of the body",
                            data: {"info": "Timers"});*/
                      },
                      child: Text(
                        provider.customTime == "" || provider.customTime == null
                            ? "Set Here"
                            : provider.customTime!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 27,
                          color: provider.isCustom ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Custom Timer",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: provider.isCustom ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () async {
                            await provider.toggleCustomTimer();
                            CoreUtils.showSnackBar(
                              context,
                              provider.isCustom
                                  ? 'Your Custom Timer has been turned ON Successfully.'
                                  : 'Your Custom Timer has been turned OFF Successfully.',
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 30,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: provider.isCustom
                                  ? Colors.black.withOpacity(0.5)
                                  : Colours.secondaryColour,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: provider.isCustom
                                      ? Colours.primaryOrange.withOpacity(0.2)
                                      : Colors.grey.shade400.withOpacity(0.7),
                                  spreadRadius: 2,
                                  blurRadius: provider.isCustom ? 10 : 2,
                                ),
                              ],
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: provider.isCustom ? Alignment.centerRight : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (provider.isLoading)
              Container(
                width: MediaQuery.of(context).size.width * .93,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}