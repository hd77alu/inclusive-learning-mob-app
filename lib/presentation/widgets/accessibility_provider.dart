import 'package:flutter/material.dart';
import '/data/services/accessibility_service.dart';

/// Provides accessibility settings throughout the widget tree
class AccessibilityProvider extends InheritedWidget {
  final AccessibilityService service;

  const AccessibilityProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static AccessibilityService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AccessibilityProvider>();
    return provider?.service ?? AccessibilityService.defaultMode;
  }

  @override
  bool updateShouldNotify(AccessibilityProvider oldWidget) {
    return service.mode != oldWidget.service.mode;
  }
}
