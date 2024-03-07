import 'package:flutter/services.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/res/media_res.dart';
import 'package:gs_orange/src/profile/presentation/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;
        String _copy = user!.uid.toString();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Row(
              children: [
                Expanded(
                  child: UserInfoCard(
                    infoThemeColour: Colours.biologyTileColour,
                    infoIcon: const Icon(
                      IconlyLight.user,
                      color: Color(0xFF56AEFF),
                      size: 24,
                    ),
                    infoTitle: 'Savings ave',
                    infoValue: user.temperature.toString(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: UserInfoCard(
                    infoThemeColour: Colours.chemistryTileColour,
                    infoIcon: const Icon(
                      IconlyLight.user,
                      color: Color(0xFFFF84AA),
                      size: 24,
                    ),
                    infoTitle: 'Total Savings',
                    infoValue: user.temperature.toString(),
                  ),
                ),
              ],
            ),*/
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text('My Unit info',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 21)),
                  Row(
                    children: [
                      Expanded(
                        child: UserInfoCard2(
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
                  Row(
                    children: [
                      Expanded(
                        child: UserInfoCard2(
                          infoThemeColour: Colours.neutralTextColour,
                          infoIcon: const Icon(
                            IconlyLight.shield_done,
                            color: Colors.white,
                            size: 24,
                          ),
                          infoTitle: 'Unit User ID',
                          infoValue: user.uid.toString(),
                        ),
                      ),
                    ],
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
