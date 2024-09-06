import 'package:flutter/services.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
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
                        child: UserInfoCard(
                          infoThemeColour: Colours.neutralTextColour,
                          infoIcon: const Icon(
                            IconlyLight.message,
                            color: Colors.white,
                            size: 24,
                          ),
                          infoTitle: 'Email',
                          infoValue: user.email.toString(),
                        ),
                      ),
                    ],
                  ),
                  Row(
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
                          infoValue: user.bio.toString(),
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
