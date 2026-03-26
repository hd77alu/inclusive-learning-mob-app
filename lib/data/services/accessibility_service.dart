import 'package:flutter/material.dart';

/// Centralized accessibility configuration based on user's selected mode
class AccessibilityService {
  final String mode;

  const AccessibilityService(this.mode);

  // Default mode - no changes
  static const AccessibilityService defaultMode = AccessibilityService('default');

  // Font size multipliers
  double get fontSizeMultiplier {
    switch (mode) {
      case 'visual':
        return 1.3;
      case 'cognitive':
        return 1.15;
      default:
        return 1.0;
    }
  }

  // Touch target size (minimum 48x48 for motor mode)
  double get minTouchTarget {
    return mode == 'motor' ? 56.0 : 48.0;
  }

  // High contrast colors
  bool get useHighContrast => mode == 'visual';

  // Animation duration (reduced for cognitive mode)
  Duration getAnimationDuration(Duration defaultDuration) {
    if (mode == 'cognitive') {
      return Duration(milliseconds: (defaultDuration.inMilliseconds * 0.5).round());
    }
    return defaultDuration;
  }

  // Disable animations completely
  bool get disableAnimations => mode == 'cognitive';

  // Simplified navigation (fewer options visible at once)
  bool get simplifiedNavigation => mode == 'cognitive';

  // Show captions/sign language indicators
  bool get showCaptions => mode == 'auditory';

  // Voice control enabled
  bool get voiceControlEnabled => mode == 'motor';

  // Screen reader support
  bool get screenReaderEnabled => mode == 'visual';

  // Button padding (larger for motor mode)
  EdgeInsets getButtonPadding(EdgeInsets defaultPadding) {
    if (mode == 'motor') {
      return EdgeInsets.all(defaultPadding.top + 4);
    }
    return defaultPadding;
  }

  // Text style with accessibility adjustments
  TextStyle adjustTextStyle(TextStyle baseStyle) {
    if (mode == 'visual') {
      return baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );
    }
    if (mode == 'cognitive') {
      return baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * fontSizeMultiplier,
        height: 1.6,
      );
    }
    return baseStyle;
  }

  // Get contrast-adjusted colors
  Color getContrastColor(Color baseColor, {required bool isDark}) {
    if (!useHighContrast) return baseColor;
    
    // Increase contrast for visual mode
    if (isDark) {
      return Color.lerp(baseColor, Colors.white, 0.2) ?? baseColor;
    } else {
      return Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor;
    }
  }
}
