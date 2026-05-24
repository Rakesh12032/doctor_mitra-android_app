import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'Poppins',
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'Poppins'),
              ),
            ),
        ],
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const AppBadge({
    super.key,
    required this.text,
    this.color = AppColors.lightBackground,
    this.textColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 56, color: AppColors.primary.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                onPressed: onAction!,
                text: buttonText!,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    if (isPrimary) {
      return Container(
        height: 52,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: color,
          gradient: color != null
              ? null
              : const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12), // 12px border radius
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: _buildContent(Colors.white),
        ),
      );
    } else {
      return SizedBox(
        height: 52,
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            backgroundColor: Colors.white,
            side: BorderSide(color: effectiveColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 12px border radius
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: _buildContent(effectiveColor),
        ),
      );
    }
  }

  Widget _buildContent(Color textColor) {
    final textWidget = Text(
      text,
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: textColor, fontFamily: 'Nunito'),
    );
    if (icon == null) return textWidget;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: textColor),
        const SizedBox(width: 8),
        textWidget,
      ],
    );
  }
}

InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Nunito'),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Nunito'),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // 10px border radius
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );

class LoginScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const LoginScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.premiumShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            PremiumHeader(title: title, subtitle: subtitle, icon: icon),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;
  final List<Widget> actions;
  final bool useGradientAppBar;

  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
    this.actions = const [],
    this.useGradientAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = useGradientAppBar ? Colors.white : AppColors.textDark;
    final subtitleColor = useGradientAppBar ? Colors.white70 : AppColors.textMuted;
    final leadingColor = useGradientAppBar ? Colors.white : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: showBack ? BackButton(color: leadingColor) : null,
        backgroundColor: Colors.transparent,
        flexibleSpace: useGradientAppBar
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            : Container(color: Colors.white),
        elevation: 0,
        titleSpacing: showBack ? 0 : 20,
        bottom: useGradientAppBar
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: AppColors.border,
                  height: 1.0,
                ),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: titleColor,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
                fontWeight: FontWeight.w400,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
        actions: actions.map((w) {
          if (useGradientAppBar) {
            return Theme(
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              child: w,
            );
          }
          return w;
        }).toList(),
      ),
      body: child,
    );
  }
}

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final int maxLines;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        decoration: inputDecoration(label, icon),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  final String text;
  const ErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppButton(
        text: label,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}

class SecondaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SecondaryAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppButton(
        text: label,
        icon: icon,
        onPressed: onPressed,
        isPrimary: false,
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.lightBackground,
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}

class PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PremiumCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class InfoStrip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoStrip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
