import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder shape;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shape = const RoundedRectangleBorder(),
  });

  const ShimmerLoader.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  }) : shape = const RoundedRectangleBorder();

  const ShimmerLoader.circular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 999.0,
  }) : shape = const CircleBorder();

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape is CircleBorder
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: widget.shape is CircleBorder
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE2E8F0), // Slate 200
                Color(0xFFF1F5F9), // Slate 100
                Color(0xFFE2E8F0), // Slate 200
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ],
            ),
          ),
        );
      },
    );
  }
}
