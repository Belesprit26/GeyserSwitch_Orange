import 'package:flutter/material.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({
    required this.infoThemeColour,
    required this.infoIcon,
    required this.infoTitle,
    required this.infoValue,
    super.key,
  });

  final Color infoThemeColour;
  final Widget infoIcon;
  final String infoTitle;
  final String infoValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: 156,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E6EA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: infoThemeColour,
                shape: BoxShape.circle,
              ),
              child: Center(child: infoIcon),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  infoTitle,
                  style: const TextStyle(fontSize: 12),
                ),
                SelectableText(
                  infoValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  onTap: () {
                    CoreUtils.showSnackBar(
                        context, 'Your UID has been copied: $infoValue');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoCard2 extends StatelessWidget {
  const UserInfoCard2({
    required this.infoThemeColour,
    required this.infoIcon,
    required this.infoTitle,
    required this.infoValue,
    super.key,
  });

  final Color infoThemeColour;
  final Widget infoIcon;
  final String infoTitle;
  final String infoValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: 156,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E6EA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: 40,
              decoration: BoxDecoration(
                color: infoThemeColour,
                shape: BoxShape.circle,
              ),
              child: Center(child: infoIcon),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  infoTitle,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  infoValue,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
