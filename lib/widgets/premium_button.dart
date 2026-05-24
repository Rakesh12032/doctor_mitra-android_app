import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final double height;
  final bool isLoading;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.icon,
    this.height = 52.0,
    this.isLoading = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.isLoading) {
          widget.onPressed();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : null,
          child: widget.isPrimary ? _buildPrimaryButton() : _buildSecondaryButton(),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF0F766E), // Deeper teal for premium depth
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _buildContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : _buildContent(AppColors.textDark),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 0.1,
      ),
    );

    if (widget.icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icon, size: 18, color: textColor),
        const SizedBox(width: 8),
        textWidget,
      ],
    );
  }
}
