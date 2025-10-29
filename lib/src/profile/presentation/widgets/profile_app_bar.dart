import 'dart:async';

import 'package:gs_orange/core/common/widgets/popup_item.dart';
import 'package:gs_orange/core/extensions/context_extension.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/services/injection_container.dart';
import 'package:gs_orange/src/auth/presentation/bloc/auth_bloc.dart';
import 'package:gs_orange/src/profile/presentation/views/edit_profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(forceMaterialTransparency: true,
      title: const Text(
        'My Profile',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
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
                title: 'Edit Profile',
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colours.neutralTextColour,
                ),
              ),
              onTap: () => context.push(
                BlocProvider(
                  create: (_) => sl<AuthBloc>(),
                  child: const EditProfileView(),
                ),
              ),
            ),
            const PopupMenuItem<void>(
              child: PopupItem(
                title: 'Help',
                icon: Icon(
                  Icons.help_outline_outlined,
                  color: Colours.neutralTextColour,
                ),
              ),
            ),
            PopupMenuItem<void>(
              height: 1,
              padding: EdgeInsets.zero,
              child: Divider(
                height: 1,
                color: Colors.grey.shade300,
                endIndent: 16,
                indent: 16,
              ),
            ),
            PopupMenuItem<void>(
              child: const PopupItem(
                title: 'Logout',
                icon: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                final navigator = Navigator.of(context);
                await sl<FirebaseAuth>().signOut();
                unawaited(
                  navigator.pushNamedAndRemoveUntil(
                    '/',
                        (route) => false,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}