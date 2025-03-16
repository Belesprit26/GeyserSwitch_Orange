import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AssetImageWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;

  const AssetImageWidget({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipOval(
              child: Container(
                width: 72,
                height: 72,
                color: Colors.transparent,
                child: AssetImageWidget(
                  imagePath: 'assets/images/GS_EC1.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  key: const ValueKey('AssetImage'),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name and Bio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'User Not Registered',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'GeyserSwitch User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
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