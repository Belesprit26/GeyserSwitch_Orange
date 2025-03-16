import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/profile/presentation/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/src/profile/presentation/refactors/presentation/connection_link_update.dart'; // Assuming this is where your ConnectionLinkProvider is

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;
        user!.uid.toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const Text(
                    'My Unit info',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 21),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: UserInfoCard(
                          infoThemeColour: Colours.neutralTextColour,
                          infoIcon: const Icon(
                            IconlyLight.message,
                            color: Colors.white,
                            size: 24,
                          ),
                          infoTitle: 'Unit Email Address',
                          infoValue: user.email.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (user.bio != null && user.bio!.isNotEmpty) Row(
                    children: [
                      Expanded(
                        child: UserInfoCard(
                          infoThemeColour: Colours.neutralTextColour,
                          infoIcon: const Icon(
                            IconlyLight.location,
                            color: Colors.white,
                            size: 24,
                          ),
                          infoTitle: 'Address',
                          infoValue: user.bio,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Adding the streaming functionality for GeyserSwitch linking info
                  Consumer<ConnectionLinkProvider>(
                    builder: (context, connectionLinkProvider, child) {
                      String displayTime = 'loading'; // Default value if updateTime is null or too short

                      // Check if updateTime is not null and long enough
                      if (connectionLinkProvider.updateTime.length > 3) {
                        displayTime =
                        'Time: ${connectionLinkProvider.updateTime.substring(0, connectionLinkProvider.updateTime.length - 3)} \nDate: ${connectionLinkProvider.updateDate}';
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: UserInfoCard(
                              infoThemeColour: Colours.neutralTextColour,
                              infoIcon: const Icon(
                                IconlyLight.time_square,
                                color: Colors.white,
                                size: 24,
                              ),
                              infoValue: displayTime,
                              infoTitle: 'Unit Last Update ',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}