import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/widgets/popup_item.dart';
import 'package:gs_orange/core/extensions/context_extension.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/timers/presentation/views/timers_view.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Home',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
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
                  title: "Log Out",
                  icon: Icon(
                    Icons.logout_outlined,
                    color: Colours.redColour,
                  )),
              onTap: () async {
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
