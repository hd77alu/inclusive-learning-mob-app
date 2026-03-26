# Accessibility Features Implementation Guide

## Goal

Create an inclusive mobile learning platform that adapts to the diverse needs of users with disabilities in Rwanda. The app should provide personalized accessibility experiences for users with visual, auditory, motor, and cognitive differences without compromising the experience for users who don't need accessibility features.

## Problem We Solved

Traditional mobile apps use a one-size-fits-all approach that creates barriers for users with disabilities:
- **Visual impairments**: Small text and low contrast make content unreadable
- **Hearing impairments**: Audio content without captions excludes deaf users
- **Motor impairments**: Small touch targets are difficult to tap accurately
- **Cognitive differences**: Complex animations and cluttered interfaces cause confusion

We needed a solution that:
1. Adapts the UI based on user needs
2. Doesn't break existing functionality
3. Is easy for developers to implement
4. Provides a seamless experience across all modes

## How We Implemented It

We built a **mode-based accessibility system** with 5 distinct modes:

1. **Architecture**:
   - `AccessibilityService`: Centralized service that provides UI adjustments (font sizes, touch targets, colors, animations) based on the selected mode
   - `AccessibilityProvider`: InheritedWidget that makes accessibility settings available throughout the widget tree
   - `Accessible Widgets`: Pre-built widgets (AccessibleText, AccessibleButton, etc.) that automatically adjust based on the current mode

2. **User Flow**:
   - User selects their accessibility mode in Profile → Accessibility
   - Preference is saved to Firestore
   - App automatically loads the preference on startup
   - All accessible widgets adjust their behavior based on the selected mode

3. **Key Design Decisions**:
   - **Default mode = no changes**: Ensures existing UI remains unchanged for users who don't need accessibility features
   - **Opt-in approach**: Only widgets explicitly using accessible components are affected
   - **Graceful fallback**: If preference loading fails, app uses default mode
   - **Non-breaking**: Developers can gradually adopt accessible widgets without breaking existing code

## Table of Contents

1. [Overview](#overview)
2. [What's Implemented](#whats-implemented)
3. [Quick Start](#quick-start)
   - [Use Accessible Widgets](#use-accessible-widgets-recommended)
   - [Manual Adjustments](#manual-adjustments)
4. [How It Works](#how-it-works)
   - [Automatic Loading](#1-automatic-loading)
   - [Global Access](#2-global-access)
   - [Automatic Adjustments](#3-automatic-adjustments)
5. [Mode Adjustments Reference](#mode-adjustments-reference)
6. [Mode-Specific Features](#mode-specific-features)
7. [Usage Examples](#usage-examples)
8. [Before & After Example](#before--after-example)
9. [Common Patterns](#common-patterns)
10. [Material Component Text](#material-component-text)
11. [Where to Apply](#where-to-apply)
12. [Testing](#testing)
13. [Best Practices](#best-practices)
14. [Important Notes](#important-notes)
15. [Screen Reader Support](#screen-reader-support-semantic-labels)
    - [Overview](#overview-1)
    - [Implementation Status](#implementation-status)
    - [Key Semantic Patterns](#key-semantic-patterns)
    - [Semantic Guidelines](#semantic-guidelines)
    - [Testing Screen Reader Support](#testing-screen-reader-support)
    - [Common Semantic Widgets](#common-semantic-widgets)
    - [Resources](#resources)
16. [State Management Architecture](#state-management-architecture)
    - [BLoC Pattern Implementation](#bloc-pattern-implementation)
    - [Architecture Overview](#architecture-overview)
    - [State Flow](#state-flow)
    - [BLoC Structure](#bloc-structure)
    - [Key Benefits](#key-benefits)
    - [Implementation Details](#implementation-details)
    - [Migration from setState](#migration-from-setstate)
    - [For Other Developers](#for-other-developers)
17. [Future Enhancements](#future-enhancements)

---

## Overview

The app supports 5 accessibility modes that automatically adjust the UI:
- **Default**: Standard UI (no changes)
- **Visual**: Larger fonts, high contrast, screen reader support
- **Auditory**: Captions, sign language indicators
- **Motor**: Larger touch targets, voice control
- **Cognitive**: Simplified navigation, reduced animations

---

## What's Implemented

1. **Accessibility Service** (`lib/data/services/accessibility_service.dart`)
   - Provides UI adjustments based on selected mode
   - Font sizes, touch targets, colors, animations

2. **Accessibility Provider** (`lib/presentation/widgets/accessibility_provider.dart`)
   - Makes settings available throughout the app
   - Automatic loading on app startup

3. **Accessible Widgets** (`lib/presentation/widgets/accessible_widgets.dart`)
   - `AccessibleText` - Auto-adjusts font size
   - `AccessibleButton` - Larger touch targets
   - `AccessibleIconButton` - Accessible icon buttons
   - `AccessibleAnimatedContainer` - Respects animation preferences

4. **Main App Integration** (`lib/main.dart`)
   - Loads preference on startup
   - Wraps app with AccessibilityProvider

5. **Setup Screen** (`lib/presentation/screens/accessibility/accessibility_setup_screen.dart`)
   - Professional UI showing current mode with features
   - Reloads app after saving preference

---

## Quick Start

### Use Accessible Widgets (Recommended)

```dart
// Instead of Text
AccessibleText('Hello', style: TextStyle(fontSize: 14))

// Instead of ElevatedButton
AccessibleButton(onPressed: () {}, child: Text('Click'))

// Instead of IconButton
AccessibleIconButton(icon: Icons.add, onPressed: () {})

// Instead of AnimatedContainer
AccessibleAnimatedContainer(duration: Duration(milliseconds: 300), child: ...)
```

### Manual Adjustments

```dart
final a11y = AccessibilityProvider.of(context);

// Adjust text style
Text('Hello', style: a11y.adjustTextStyle(TextStyle(fontSize: 14)))

// Get touch target size
Container(
  constraints: BoxConstraints(
    minWidth: a11y.minTouchTarget,
    minHeight: a11y.minTouchTarget,
  ),
)

// Check mode flags
if (a11y.showCaptions) { /* Show captions */ }
if (a11y.disableAnimations) { /* Skip animation */ }
```

---

## How It Works

### 1. Automatic Loading
The accessibility preference is loaded automatically when the app starts in `main.dart`:
```dart
// Loads user's saved preference from Firestore
_loadAccessibilityPreference()
```

### 2. Global Access
Any widget can access accessibility settings:
```dart
final a11y = AccessibilityProvider.of(context);
```

### 3. Automatic Adjustments
Use the provided accessible widgets for automatic adjustments:

#### AccessibleText
```dart
// Automatically adjusts font size based on mode
AccessibleText(
  'Hello World',
  style: TextStyle(fontSize: 14),
)
```

#### AccessibleButton
```dart
// Larger touch targets in motor mode
AccessibleButton(
  onPressed: () {},
  child: Text('Click Me'),
)
```

#### AccessibleIconButton
```dart
// Larger touch targets for icons
AccessibleIconButton(
  icon: Icons.settings,
  onPressed: () {},
  tooltip: 'Settings',
)
```

#### AccessibleAnimatedContainer
```dart
// Respects cognitive mode (reduced/no animations)
AccessibleAnimatedContainer(
  duration: Duration(milliseconds: 300),
  color: Colors.blue,
  child: Text('Animated'),
)
```

---

## Mode Adjustments Reference

| Feature | Default | Visual | Auditory | Motor | Cognitive |
|---------|---------|--------|----------|-------|-----------|
| Font Size | 1.0x | 1.3x | 1.0x | 1.0x | 1.15x |
| Touch Target | 48px | 48px | 48px | 56px | 48px |
| High Contrast | No | Yes | No | No | No |
| Animations | Full | Full | Full | Full | 50% / Off |
| Captions | No | No | Yes | No | No |
| Voice Control | No | No | No | Yes | No |

---

## Mode-Specific Features

### Visual Mode
- Font size: 1.3x larger
- High contrast colors
- Screen reader enabled
- Increased line height (1.5)
- Bold text (FontWeight.w600)

### Auditory Mode
- Show captions indicator
- Sign language support flag
- Visual feedback for audio cues

### Motor Mode
- Touch targets: 56x56 (vs 48x48)
- Larger button padding (+4px)
- Voice control enabled
- Switch access support

### Cognitive Mode
- Font size: 1.15x larger
- Animations reduced by 50%
- Simplified navigation
- Increased line height (1.6)
- Focus mode enabled

---

## Usage Examples

### Example 1: Accessible Card
```dart
Widget buildCard() {
  final a11y = AccessibilityProvider.of(context);
  
  return AccessibleAnimatedContainer(
    duration: Duration(milliseconds: 300),
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        AccessibleText(
          'Card Title',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        AccessibleButton(
          onPressed: () {},
          child: Text('Action'),
        ),
      ],
    ),
  );
}
```

### Example 2: Conditional Features
```dart
Widget buildVideoPlayer() {
  final a11y = AccessibilityProvider.of(context);
  
  return Stack(
    children: [
      VideoPlayer(...),
      
      // Show captions in auditory mode
      if (a11y.showCaptions)
        Positioned(
          bottom: 20,
          child: CaptionsWidget(),
        ),
    ],
  );
}
```

### Example 3: Simplified Navigation
```dart
Widget buildNavigation() {
  final a11y = AccessibilityProvider.of(context);
  
  final items = [
    'Home',
    'Courses',
    'Profile',
    if (!a11y.simplifiedNavigation) 'Settings',
    if (!a11y.simplifiedNavigation) 'Help',
  ];
  
  return BottomNavigationBar(items: ...);
}
```

### Example 4: Font Sizes
```dart
final a11y = AccessibilityProvider.of(context);
Text(
  'Custom text',
  style: a11y.adjustTextStyle(TextStyle(fontSize: 16)),
)
```

### Example 5: Colors (High Contrast)
```dart
final a11y = AccessibilityProvider.of(context);
final isDark = Theme.of(context).brightness == Brightness.dark;
Color adjustedColor = a11y.getContrastColor(Colors.blue, isDark: isDark);
```

### Example 6: Touch Targets
```dart
final a11y = AccessibilityProvider.of(context);
Container(
  constraints: BoxConstraints(
    minWidth: a11y.minTouchTarget,  // 56 in motor mode, 48 otherwise
    minHeight: a11y.minTouchTarget,
  ),
  child: Icon(Icons.add),
)
```

### Example 7: Animations
```dart
final a11y = AccessibilityProvider.of(context);

// Adjust duration
AnimatedContainer(
  duration: a11y.getAnimationDuration(Duration(milliseconds: 300)),
  ...
)

// Or disable completely
if (!a11y.disableAnimations) {
  // Show animation
}
```

### Example 8: Button Padding
```dart
final a11y = AccessibilityProvider.of(context);
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: a11y.getButtonPadding(EdgeInsets.all(12)),
  ),
  ...
)
```

---

## Before & After Example

### Before (Standard Widget)

```dart
Widget buildCard() {
  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          'Course Title',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Course description goes here',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: Text('Enroll Now'),
        ),
        SizedBox(height: 8),
        IconButton(
          icon: Icon(Icons.bookmark_border),
          onPressed: () {},
        ),
      ],
    ),
  );
}
```

### After (Accessible Widgets)

```dart
Widget buildCard() {
  return AccessibleAnimatedContainer(
    duration: Duration(milliseconds: 300),
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        AccessibleText(
          'Course Title',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        AccessibleText(
          'Course description goes here',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 16),
        AccessibleButton(
          onPressed: () {},
          child: Text('Enroll Now'),
        ),
        SizedBox(height: 8),
        AccessibleIconButton(
          icon: Icons.bookmark_border,
          onPressed: () {},
          tooltip: 'Bookmark course',
        ),
      ],
    ),
  );
}
```

### What Changed?

1. `AnimatedContainer` → `AccessibleAnimatedContainer`
   - Respects cognitive mode (reduced/no animations)

2. `Text` → `AccessibleText`
   - Auto-adjusts font size in visual/cognitive modes
   - Increases line height for readability

3. `ElevatedButton` → `AccessibleButton`
   - Larger touch targets in motor mode (56x56 vs 48x48)

4. `IconButton` → `AccessibleIconButton`
   - Larger touch targets in motor mode
   - Better tooltip support for screen readers

### Result

#### Default Mode
- Looks exactly the same as before

#### Visual Mode
- Title: 18px → 23.4px (1.3x)
- Description: 14px → 18.2px (1.3x)
- High contrast colors
- Bold text for better readability

#### Motor Mode
- Button: 48x48 → 56x56 touch target
- Icon: 48x48 → 56x56 touch target
- Easier to tap

#### Cognitive Mode
- Title: 18px → 20.7px (1.15x)
- Description: 14px → 16.1px (1.15x)
- Animation: 300ms → 150ms (50% faster)
- Increased line spacing

---

## Common Patterns

### Pattern 1: Conditional Features
```dart
final a11y = AccessibilityProvider.of(context);

if (a11y.showCaptions) {
  // Show caption indicator
  Icon(Icons.closed_caption, color: Colors.white)
}
```

### Pattern 2: Adjusted Spacing
```dart
final a11y = AccessibilityProvider.of(context);

SizedBox(
  height: a11y.mode == 'visual' ? 20 : 12,
)
```

### Pattern 3: Simplified UI
```dart
final a11y = AccessibilityProvider.of(context);

if (!a11y.simplifiedNavigation) {
  // Show advanced options
  AdvancedSettingsButton()
}
```

---

## Material Component Text

**Important**: Text widgets inside Material components (Chip, ChoiceChip, buttons, tabs, dialogs) don't automatically inherit accessibility settings from `AccessibleText` wrapper.

### Solution: Apply font multiplier directly

```dart
final a11y = AccessibilityProvider.of(context);

// For Chips
ChoiceChip(
  label: Text('Category'),
  labelStyle: TextStyle(
    fontSize: 12 * a11y.fontSizeMultiplier,
    fontWeight: FontWeight.w600,
  ),
)

// For Tab labels
TabBar(
  labelStyle: TextStyle(
    fontSize: 14 * a11y.fontSizeMultiplier,
    fontWeight: FontWeight.w700,
  ),
  tabs: [...]
)

// For Dialog text
AlertDialog(
  title: Text(
    'Title',
    style: TextStyle(fontSize: 16 * a11y.fontSizeMultiplier),
  ),
  content: Text(
    'Content',
    style: TextStyle(fontSize: 13 * a11y.fontSizeMultiplier),
  ),
)
```

---

## Where to Apply

### High Priority (Apply First)
- Buttons and interactive elements
- Text content (headings, body text)
- Navigation elements
- Form inputs

### Medium Priority
- Cards and containers
- Animations and transitions
- Icons and images
- Chips and tags

### Low Priority
- Decorative elements
- Background animations
- Non-critical UI

---

## Testing

### Testing Different Modes

1. Go to Profile → Accessibility
2. Select a mode (Visual, Auditory, Motor, or Cognitive)
3. Save preference
4. App reloads with new settings applied

### Testing Checklist

- [ ] Test all 5 modes (Default, Visual, Auditory, Motor, Cognitive)
- [ ] Verify text is readable in Visual mode
- [ ] Check touch targets are larger in Motor mode
- [ ] Confirm animations are reduced in Cognitive mode
- [ ] Ensure default mode looks unchanged
- [ ] Test Material component text (chips, tabs, dialogs)

---

## Best Practices

1. **Use Accessible Widgets**: Prefer `AccessibleText`, `AccessibleButton`, etc.
2. **Check Mode Flags**: Use `a11y.showCaptions`, `a11y.voiceControlEnabled`, etc.
3. **Respect Animations**: Always check `a11y.disableAnimations`
4. **Test All Modes**: Verify UI works in all 5 modes
5. **Semantic Labels**: Add tooltips and semantic labels for screen readers
6. **Material Components**: Apply font multipliers directly to Material component text
7. **Start Small**: Update one screen at a time
8. **Test Immediately**: Check all 5 modes after each change
9. **Keep It Simple**: Don't over-engineer
10. **Document**: Note any custom implementations

---

## Important Notes

1. **Non-Breaking**: Default mode = current UI (no changes)
2. **Opt-In**: Only widgets you update will have adjustments
3. **Graceful**: If preference fails to load, uses default mode
4. **Testable**: Change mode in Profile → Accessibility
5. **Material Components**: Need explicit font multipliers (see [Material Component Text](#material-component-text))

---

## Screen Reader Support (Semantic Labels)

### Overview

The app implements comprehensive semantic labels for screen reader compatibility (TalkBack on Android, VoiceOver on iOS). All 20+ screens have been enhanced with proper semantic annotations to ensure users with visual impairments can navigate and use the app effectively.

### Implementation Status

**Completed:**
- Authentication screens (sign up, sign in, password reset, email verification)
- Core navigation (bottom navigation bar with tab announcements)
- Course discovery (search, filters, course cards with progress/bookmark status)
- Mentorship hub (mentor cards, profiles, session booking)
- Profile & settings (preferences, accessibility setup)
- Skills management (skill cards, add/edit/delete operations)
- Session management (upcoming/past sessions)

### Key Semantic Patterns

#### 1. Interactive Elements
```dart
// Buttons with labels and hints
Semantics(
  button: true,
  label: 'Sign in to your account',
  hint: 'Double tap to sign in',
  child: ElevatedButton(...),
)
```

#### 2. Form Fields
```dart
// Text fields with labels
Semantics(
  textField: true,
  label: 'Search courses',
  hint: 'Enter course name or category',
  child: TextField(...),
)
```

#### 3. Selection States
```dart
// Chips and toggles with selection announcements
Semantics(
  button: true,
  selected: isSelected,
  label: 'Digital Skills category',
  hint: isSelected ? 'Currently selected' : 'Tap to filter courses',
  child: ChoiceChip(...),
)
```

#### 4. Dynamic Status
```dart
// Live regions for status updates
Semantics(
  label: 'Online now',
  liveRegion: true,
  child: OnlineBadge(...),
)
```

#### 5. Complex Cards
```dart
// Course cards with comprehensive context
Semantics(
  button: true,
  label: 'Flutter Development, Digital Skills, 26 minutes. In progress, 45 percent complete. Bookmarked.',
  hint: 'Double tap to view course details',
  child: CourseCard(...),
)
```

#### 6. Password Toggles
```dart
// Password visibility with state-aware labels
Semantics(
  label: passwordVisible ? 'Hide password' : 'Show password',
  hint: 'Double tap to toggle password visibility',
  child: IconButton(...),
)
```

### Semantic Guidelines

**Do:**
- Provide clear, concise labels that describe the element's purpose
- Include contextual information (e.g., "Tab 1 of 4", "45% complete")
- Announce selection states ("Currently selected", "Not selected")
- Use hints to explain what happens when activated
- Mark decorative elements with `ExcludeSemantics`
- Use `liveRegion: true` for dynamic status updates

**Don't:**
- Duplicate visible text in semantic labels
- Use overly verbose descriptions
- Forget to announce state changes
- Leave interactive elements without labels
- Use technical jargon in labels

### Testing Screen Reader Support

**Android (TalkBack):**
1. Settings → Accessibility → TalkBack → Enable
2. Navigate with swipe gestures
3. Double-tap to activate elements
4. Verify all elements are announced clearly

**iOS (VoiceOver):**
1. Settings → Accessibility → VoiceOver → Enable
2. Navigate with swipe gestures
3. Double-tap to activate elements
4. Verify all elements are announced clearly

### Common Semantic Widgets

```dart
// Button
Semantics(
  button: true,
  label: 'Descriptive label',
  hint: 'What happens when tapped',
  child: Widget(...),
)

// Image
Semantics(
  image: true,
  label: 'Description of image content',
  child: Image(...),
)

// Toggle/Switch
Semantics(
  toggled: isEnabled,
  label: 'Feature name, ${isEnabled ? "enabled" : "disabled"}',
  hint: 'Double tap to toggle',
  child: Switch(...),
)

// Text field
Semantics(
  textField: true,
  label: 'Field purpose',
  hint: 'Input instructions',
  child: TextField(...),
)

// Decorative element
ExcludeSemantics(
  child: DecorativeIcon(...),
)
```

### Resources

- [Flutter Semantics Widget](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Screen Reader Testing](https://docs.flutter.dev/development/accessibility-and-localization/accessibility#screen-readers)

---

## State Management Architecture

### BLoC Pattern Implementation

The accessibility system uses **BLoC (Business Logic Component)** pattern for state management, ensuring clean separation of concerns and maintainable code.

#### Architecture Overview

**Key Components:**
1. **AccessibilityBloc** (`lib/blocs/accessibility_bloc.dart`) - Manages all accessibility state
2. **AccessibilityService** - Provides UI adjustments based on mode
3. **AccessibilityProvider** - Makes service available throughout widget tree
4. **Accessible Widgets** - Auto-adjust based on current mode

#### State Flow

**Loading on App Start:**
```
1. MainApp builds
2. AccessibilityBloc created with LoadAccessibilityPreference event
3. BLoC loads preference from Firestore
4. BLoC emits AccessibilityLoaded with service
5. AccessibilityProvider rebuilds with new service
6. All accessible widgets automatically update
```

**Saving Preference:**
```
1. User selects mode in AccessibilitySetupScreen
2. User taps "Save Changes"
3. BLoC receives SaveAccessibilityPreference event
4. BLoC saves to Firestore
5. BLoC emits AccessibilitySaved with new service
6. Navigation to home screen
7. BlocListener in AuthGate shows success message
8. AccessibilityProvider rebuilds with new service
9. All accessible widgets automatically update
```

#### BLoC Structure

**Events:**
```dart
abstract class AccessibilityEvent {}

class LoadAccessibilityPreference extends AccessibilityEvent {}

class SelectAccessibilityMode extends AccessibilityEvent {
  final String mode;
  SelectAccessibilityMode(this.mode);
}

class SaveAccessibilityPreference extends AccessibilityEvent {
  final String mode;
  SaveAccessibilityPreference(this.mode);
}
```

**States:**
```dart
abstract class AccessibilityState {
  final AccessibilityService service;
  AccessibilityState(this.service);
}

class AccessibilityInitial extends AccessibilityState {}
class AccessibilityLoading extends AccessibilityState {}
class AccessibilityLoaded extends AccessibilityState {
  final AccessibilityPreference? preference;
  final String? pendingSelection;
}
class AccessibilitySaving extends AccessibilityState {}
class AccessibilitySaved extends AccessibilityState {
  final bool showSuccessMessage;
}
class AccessibilityError extends AccessibilityState {}
```

#### Key Benefits

**1. Separation of Concerns**
- Business logic in `blocs/` folder
- UI logic in `presentation/` folder
- No business logic in UI files

**2. Testability**
- BLoC can be unit tested independently
- No need to test UI to test business logic
- Easy to mock dependencies

**3. Maintainability**
- Single source of truth for accessibility state
- Predictable state changes
- Easy to debug with BLoC observer
- Less boilerplate code

**4. Scalability**
- Easy to add new accessibility features
- Can add more events/states without touching UI
- Consistent pattern across the app

#### Implementation Details

**MainApp Setup:**
```dart
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccessibilityBloc>(
          create: (_) => AccessibilityBloc(FirestoreService())
            ..add(LoadAccessibilityPreference()),
        ),
        // ... other providers
      ],
      child: BlocBuilder<AccessibilityBloc, AccessibilityState>(
        builder: (context, a11yState) {
          return AccessibilityProvider(
            service: a11yState.service,
            child: MaterialApp(...),
          );
        },
      ),
    );
  }
}
```

**Setup Screen Usage:**
```dart
// Uses the global BLoC from main.dart
class AccessibilitySetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AccessibilityBloc, AccessibilityState>(
      listener: (context, state) {
        if (state is AccessibilitySaved) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        }
      },
      child: BlocBuilder<AccessibilityBloc, AccessibilityState>(
        builder: (context, state) {
          final selectedMode = state is AccessibilityLoaded 
            ? state.effectiveMode 
            : null;
          // ... UI
        },
      ),
    );
  }
}
```

**Success Message:**
```dart
// In AuthGate (home route)
BlocListener<AccessibilityBloc, AccessibilityState>(
  listener: (context, state) {
    if (state is AccessibilitySaved && state.showSuccessMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accessibility preference saved!')),
      );
    }
  },
  child: // ... screens
)
```

#### Migration from setState

The accessibility system was refactored from `setState` to BLoC pattern:

**Before (setState):**
- `MainApp` was a `StatefulWidget` with local state
- Used `setState` to update `_accessibilityService`
- Business logic mixed with UI in `main.dart`
- Manual state management with `initState`, `mounted` checks

**After (BLoC):**
- `MainApp` is now a `StatelessWidget`
- All state managed by `AccessibilityBloc`
- Business logic in `lib/blocs/accessibility_bloc.dart`
- Automatic state updates via BLoC streams
- Removed 60+ lines of state management code

#### For Other Developers

If you're working on features that need global state:

1. **Create a BLoC** in `lib/blocs/` folder
2. **Define Events** for user actions
3. **Define States** for different UI states
4. **Implement handlers** for each event
5. **Use BlocProvider** at the appropriate level
6. **Use BlocBuilder** to rebuild UI
7. **Use BlocListener** for side effects (navigation, snackbars)

**Example Pattern:**
```dart
// 1. Create BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc() : super(FeatureInitial()) {
    on<LoadFeature>(_onLoad);
  }
  
  Future<void> _onLoad(LoadFeature event, Emitter<FeatureState> emit) async {
    emit(FeatureLoading());
    try {
      final data = await repository.load();
      emit(FeatureLoaded(data));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}

// 2. Provide BLoC
BlocProvider(
  create: (_) => FeatureBloc()..add(LoadFeature()),
  child: FeatureScreen(),
)

// 3. Build UI
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state is FeatureLoading) return LoadingWidget();
    if (state is FeatureLoaded) return DataWidget(state.data);
    if (state is FeatureError) return ErrorWidget(state.message);
    return SizedBox();
  },
)
```

---

## Future Enhancements

- [ ] Voice control integration
- [ ] Sign language video overlays
- [ ] Switch access navigation
- [ ] Focus mode UI simplification
- [ ] Haptic feedback for motor mode
