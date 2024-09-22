import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/media_res.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;
        final cachedImage = provider.cachedProfileImagePath;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.transparent,
              backgroundImage: cachedImage != null
                  ? FileImage(File(cachedImage))
                  : (user?.profilePic != null && user!.profilePic!.isNotEmpty
                  ? NetworkImage(user.profilePic!)
                  : const AssetImage(MediaRes.user)) as ImageProvider,
            ),
            const SizedBox(width: 16),

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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                       'GeyserSwitch User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12, // Slightly smaller for bio
                        color: Colors.grey,
                      ),
                    ),
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