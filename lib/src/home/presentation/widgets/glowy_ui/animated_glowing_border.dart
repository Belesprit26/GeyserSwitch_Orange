import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/widgets/glowy_ui/glowing_borders.dart';

class AnimatedGlowingBorder extends StatefulWidget {
  final Widget child;
  final double glowWidth;
  final double borderRadius;
  final List<Color> glowColors;
  final Duration duration;
  final bool isActive;

  const AnimatedGlowingBorder({
    Key? key,
    required this.child,
    this.glowWidth = 10.0,
    this.borderRadius = 16.0,
    required this.glowColors,
    this.duration = const Duration(seconds: 4),
    this.isActive = true,
  }) : super(key: key);

  @override
  _AnimatedGlowingBorderState createState() => _AnimatedGlowingBorderState();
}

class _AnimatedGlowingBorderState extends State<AnimatedGlowingBorder>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Color?>? _colorAnimation;
  late List<TweenSequenceItem<Color?>> _colorTweenItems;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    // Create a sequence of color tweens
    _colorTweenItems = [];
    for (int i = 0; i < widget.glowColors.length; i++) {
      final nextIndex = (i + 1) % widget.glowColors.length;
      _colorTweenItems.add(
        TweenSequenceItem(
          tween: ColorTween(
            begin: widget.glowColors[i],
            end: widget.glowColors[nextIndex],
          ),
          weight: 1.0,
        ),
      );
    }

    _colorAnimation = _controller!.drive(
      TweenSequence(_colorTweenItems),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedGlowingBorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        // Initialize and start the animation
        _initializeAnimation();
        setState(() {});
      } else {
        // Dispose of the animation controller
        _controller?.dispose();
        _controller = null;
        _colorAnimation = null;
        setState(() {}); // Rebuild without animation
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive && _controller != null && _colorAnimation != null) {
      // When active, use AnimatedBuilder to animate the glow
      return AnimatedBuilder(
        animation: _colorAnimation!,
        builder: (context, child) {
          return GlowingBorder(
            glowWidth: widget.glowWidth,
            glowColor: _colorAnimation!.value ?? widget.glowColors.first,
            borderRadius: widget.borderRadius,
            child: widget.child,
          );
        },
      );
    } else {
      // When inactive, return a static widget without animation
      return GlowingBorder(
        glowWidth: widget.glowWidth,
        glowColor: widget.glowColors.first, // Or use a static color
        borderRadius: widget.borderRadius,
        child: widget.child,
      );
    }
  }
}