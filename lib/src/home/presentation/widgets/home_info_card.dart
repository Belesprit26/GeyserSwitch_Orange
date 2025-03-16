import 'package:flutter/material.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class HomerInfoCard extends StatefulWidget {
  const HomerInfoCard({
    required this.infoThemeColour,
    required this.infoIcon,
    required this.infoTitle,
    this.infoValue,
    this.extraWidget,
    this.infoTitleTextStyle,
    super.key,
  });

  final Color infoThemeColour;
  final Widget infoIcon;
  final String infoTitle;
  final String? infoValue;
  final Widget? extraWidget;
  final TextStyle? infoTitleTextStyle;

  @override
  State<HomerInfoCard> createState() => _HomerInfoCardState();
}

class _HomerInfoCardState extends State<HomerInfoCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasExtraWidget = widget.extraWidget != null;
    final hasInfoValue = widget.infoValue != null && widget.infoValue!.isNotEmpty;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E6EA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 8.0),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: widget.infoThemeColour,
                shape: BoxShape.circle,
              ),
              child: Center(child: widget.infoIcon),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.infoTitle,
                    style: widget.infoTitleTextStyle ?? const TextStyle(fontSize: 13),
                  ),
                  if (hasExtraWidget) widget.extraWidget!,
                  if (hasInfoValue) ...[
                    GestureDetector(
                      onTap: () {
                        CoreUtils.showSnackBar(
                          context,
                          'Click on the 3 dots to edit your details.',
                        );
                      },
                      child: Text(
                        widget.infoValue!,
                        maxLines: _isExpanded ? null : 2,
                        overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(_isExpanded ? 'Show less' : 'Show more'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}