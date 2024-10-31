import 'package:flutter/material.dart';

class GlowingBorderPainter extends CustomPainter {
  final double glowWidth;
  final Color glowColor;
  final double borderRadius;

  GlowingBorderPainter({
    required this.glowWidth,
    required this.glowColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(
      rect.inflate(glowWidth / 2),
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowWidth);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlowingBorderPainter oldDelegate) {
    return oldDelegate.glowWidth != glowWidth ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}