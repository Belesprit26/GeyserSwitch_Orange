import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/widgets/nested_back_button.dart';

class TimersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TimersAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Timer Automation',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
      ),
      centerTitle: true,
      leading: const NestedBackButton(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
