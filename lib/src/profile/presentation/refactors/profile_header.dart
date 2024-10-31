import 'dart:async';
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

  Future<bool> _loadNetworkImage(String? profilePicUrl) async {
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      final image = NetworkImage(profilePicUrl);
      final completer = Completer<bool>();

      image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
              (info, isSync) => completer.complete(true),
          onError: (error, stackTrace) => completer.complete(false),
        ),
      );

      return completer.future;
    }
    return false; // Return false if no network image is available
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;
        final profilePicUrl = user?.profilePic;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FutureBuilder<bool>(
              future: _loadNetworkImage(profilePicUrl),
              builder: (context, snapshot) {
                return ClipOval(
                  child: Container(
                    width: 72,
                    height: 72,
                    color: Colors.transparent,
                    child: AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: snapshot.connectionState == ConnectionState.done &&
                          snapshot.data == true
                          ? Image.network(
                        profilePicUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        key: const ValueKey('NetworkImage'),
                      )
                          : AssetImageWidget(
                        imagePath: 'assets/images/GS_EC1.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                        key: const ValueKey('AssetImage'),
                      ),
                    ),
                  ),
                );
              },
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