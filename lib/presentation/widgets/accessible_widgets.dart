import 'package:flutter/material.dart';
import '/presentation/widgets/accessibility_provider.dart';

/// Text widget that automatically adjusts based on accessibility settings
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityProvider.of(context);
    final adjustedStyle = style != null ? a11y.adjustTextStyle(style!) : null;

    return Semantics(
      label: semanticsLabel ?? text,
      child: Text(
        text,
        style: adjustedStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Button with accessibility-aware touch targets and padding
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? semanticsLabel;
  final String? semanticsHint;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityProvider.of(context);
    
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel,
      hint: semanticsHint,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style?.copyWith(
          minimumSize: WidgetStateProperty.all(
            Size(a11y.minTouchTarget, a11y.minTouchTarget),
          ),
        ) ?? ElevatedButton.styleFrom(
          minimumSize: Size(a11y.minTouchTarget, a11y.minTouchTarget),
        ),
        child: child,
      ),
    );
  }
}

/// Icon button with larger touch targets for motor mode
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final String? semanticsLabel;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityProvider.of(context);
    
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel ?? tooltip,
      hint: 'Double tap to activate',
      child: IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        color: color,
        tooltip: tooltip,
        constraints: BoxConstraints(
          minWidth: a11y.minTouchTarget,
          minHeight: a11y.minTouchTarget,
        ),
      ),
    );
  }
}

/// Animated widget that respects cognitive mode (reduced/no animations)
class AccessibleAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;

  const AccessibleAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityProvider.of(context);
    
    if (a11y.disableAnimations) {
      return Container(
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: decoration,
        width: width,
        height: height,
        child: child,
      );
    }

    return AnimatedContainer(
      duration: a11y.getAnimationDuration(duration),
      curve: curve,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Helper to get accessibility-adjusted colors
extension AccessibleColors on BuildContext {
  Color getAccessibleColor(Color baseColor) {
    final a11y = AccessibilityProvider.of(this);
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return a11y.getContrastColor(baseColor, isDark: isDark);
  }
}
