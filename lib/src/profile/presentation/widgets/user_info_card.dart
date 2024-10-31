import 'package:flutter/material.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({
    required this.infoThemeColour,
    required this.infoIcon,
    required this.infoTitle,
    this.infoValue,  // Nullable infoValue field
    this.extraWidget,  // Nullable extraWidget field
    super.key,
  });

  final Color infoThemeColour;
  final Widget infoIcon;
  final String infoTitle;
  final String? infoValue;  // Nullable infoValue
  final Widget? extraWidget;  // Nullable extraWidget field

  @override
  Widget build(BuildContext context) {
    return Container(
      height: extraWidget != null ? 120 : 90,  // Adjust height if extraWidget is present
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E6EA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 9.0),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: infoThemeColour,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: infoIcon),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        infoTitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (extraWidget != null) ...[
                        extraWidget!,
                      ],
                      if (infoValue != null) ...[
                        SelectableText(
                          infoValue!,  // Fallback if infoValue is null
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          onTap: () {
                            CoreUtils.showSnackBar(
                                context, 'Click on the 3 dots to edit your details.');
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
