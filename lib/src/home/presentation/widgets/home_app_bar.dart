import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/widgets/popup_item.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/esp_32/wifi_provisioning.dart';
import 'package:gs_orange/src/home/presentation/widgets/asset_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/common/app/providers/user_provider.dart';
import '../../../../core/utils/time-helper.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  _HomeAppBarState createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool isLoading = true; // Initial loading state

  @override
  void initState() {
    super.initState();
    // Simulate loading (you should replace this with actual async loading logic)
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<UserProvider>(
        builder: (_, provider, __) {
          final user = provider.user;
         // final cachedImage = provider.cachedProfileImagePath;

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile Image
              /*CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                backgroundImage:
                const AssetImage("assets/images/GS_EC1.png"),
              ),*/
              AssetImageWidget(imagePath: 'assets/images/GS_EC1.png', width: 60, height: 60, fit: BoxFit.contain,),
              const SizedBox(width: 15),
              // Name and Bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'No User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21, // Adjust to match the boldness in screenshot
                      ),
                    ),
                    Text(
                      'Good ${TimeHelper.getTimeOfTheDay()} ${user!.fullName.split(' ').first}' ??
                          'Good Morning',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12, // Slightly smaller for bio
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        PopupMenuButton(
          offset: const Offset(0, 50),
          surfaceTintColor: Colors.white,
          icon: const Icon(Icons.more_horiz),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          itemBuilder: (_) => [
            PopupMenuItem<void>(
              child: const PopupItem(
                title: "(Re)Set Credentials",
                icon: Icon(
                  Icons.upload,
                  color: Colours.neutralTextColour,
                ),
              ),
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WiFiConfigPage(),
                  ),
                );
              },
            ),
            PopupMenuItem<void>(
              child: const PopupItem(
                title: "Log Out",
                icon: Icon(
                  Icons.logout_outlined,
                  color: Colours.redColour,
                ),
              ),
              onTap: () async {
                // Clear cached image from SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('profileImagePath'); // Remove the cached image path
                // Clear the user state (e.g., user provider)
                Provider.of<UserProvider>(context, listen: false).user = null;

                final navigator = Navigator.of(context);
                await FirebaseAuth.instance.signOut();
                navigator.pushNamedAndRemoveUntil("/", (route) => false);
              },
            ),
          ],
        ),
      ],
    );
  }
}