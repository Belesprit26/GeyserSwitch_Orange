import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/widgets/glowy_ui/glowing_border_painter.dart';

class GlowingBorder extends StatelessWidget {
  final Widget child;
  final double glowWidth;
  final Color glowColor;
  final double borderRadius;

  const GlowingBorder({
    Key? key,
    required this.child,
    this.glowWidth = 10.0,
    this.glowColor = Colors.blue,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GlowingBorderPainter(
        glowWidth: glowWidth,
        glowColor: glowColor,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}