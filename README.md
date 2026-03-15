# Inclusive Learning Platform

A Flutter mobile application built for Group 2 — an inclusive e-learning platform that supports learners with diverse accessibility needs, connecting them with mentors and structured learning content.

---

## Team

| Name | Role |
|---|---|
| Group 2 | Flutter Development |

---

## Features Implemented

### Screens

| Screen | Description |
|---|---|
| **Home (OutlookScreen)** | Landing page with navigation grid to all features |
| **Accessibility Setup** | Onboarding screen — user selects their accessibility need (Visual, Auditory, Motor, Cognitive). Saves to Firestore. |
| **Sign Up** | Google Sign-In and Anonymous (Guest) sign-in via Firebase Auth |
| **Course Completion** | Congratulations screen with certificate of completion |
| **Discover** | Browse and search courses by category. Filter chips, search bar, bookmark, progress tracking, and native share. |
| **Mentorship Hub** | Browse mentors, search by specialty, save/bookmark mentors, call/video session dialogs |
| **Mentor Profile** | Detailed mentor profile view |
| **Profile** | User profile with logout |
| **My Skills** | Full CRUD — add, edit, delete personal skills stored in Firestore |
| **Preferences** | App settings — dark mode, notifications, language |

---

## New Screens Added (Assignment)

### Accessibility Setup Screen
- Auth guarded — redirects to sign-up if not authenticated
- Loads previously saved preference from Firestore on open
- 4 selectable options: Visual, Auditory, Motor, Cognitive
- Animated tile selection with radio indicator
- Saves selection to Firestore on Continue via `AccessibilityBloc`
- Responsive layout — list on narrow screens, grid on wide screens
- Yellow to teal gradient hero card matching Figma prototype
- Error handling with styled snackbars

### Discover Screen
- Auth guarded — redirects to sign-up if not authenticated
- Courses loaded from Firestore — auto-seeds 6 courses on first run
- Per-user course progress and bookmarks stored in Firestore
- Search bar with live filtering
- Category filter chips (All, Digital Skills, Sign Language, Braille, Vocational)
- Staggered fade and slide card animations
- Progress bar shown on started/completed courses
- NEW and DONE badges on course cards
- Bookmark toggle with optimistic UI update
- Progress dialog with slider — updates Firestore on drag end
- Native share sheet using share_plus
- Responsive — 2-column grid on tablets/landscape, list on phones
- Error handling with styled snackbars

---

## Architecture

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── mentor_model.dart
│   ├── skill_model.dart
│   ├── course_model.dart
│   ├── course_progress_model.dart
│   └── accessibility_model.dart
├── blocs/
│   ├── mentorship_bloc.dart
│   ├── skills_bloc.dart
│   ├── discover_bloc.dart
│   └── accessibility_bloc.dart
├── services/
│   └── firestore_service.dart
└── presentation/
    └── screens/
        ├── app_outlook_screen.dart
        ├── sign_up_screen.dart
        ├── course_completion_screen.dart
        ├── mentorship_hub_screen.dart
        ├── mentor_profile_screen.dart
        ├── profile_screen.dart
        ├── my_skills_screen.dart
        ├── preferences_screen.dart
        ├── discover_screen.dart
        └── accessibility_setup_screen.dart
```

---

## State Management

This project uses the BLoC pattern via flutter_bloc for all state management:

| BLoC | Purpose |
|---|---|
| `MentorshipBloc` | Load mentors, toggle bookmarks |
| `SkillsBloc` | Full CRUD for user skills |
| `DiscoverBloc` | Load courses, filter, search, bookmark, update progress |
| `AccessibilityBloc` | Load, select and save accessibility preference |

---

## Firebase Backend

### Authentication
- Google Sign-In via google_sign_in and firebase_auth
- Anonymous sign-in (Guest mode)

### Firestore Collections

```
firestore/
├── courses/
│   └── {courseId}
│       ├── title, module, description
│       ├── category, duration, iconName
│       └── isNew
├── mentors/
│   └── {mentorId}
│       ├── name, role, rating
│       ├── description, tags
│       └── isOnline
└── users/
    └── {userId}/
        ├── bookmarks/
        ├── skills/
        ├── course_progress/
        └── settings/
            └── accessibility
```

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /courses/{doc} {
      allow read: if request.auth != null;
    }
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
        && request.auth.uid == userId;
    }
  }
}
```

---

## Packages Used

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | State management |
| `firebase_core` | ^4.5.0 | Firebase initialisation |
| `firebase_auth` | ^6.2.0 | Authentication |
| `cloud_firestore` | ^6.1.3 | Database |
| `google_sign_in` | ^6.2.1 | Google OAuth |
| `shared_preferences` | ^2.2.2 | Local preferences |
| `share_plus` | ^10.0.0 | Native share sheet |

---

## Getting Started

### Prerequisites
- Flutter SDK >= 3.10.7
- Android emulator with Google Play Services
- Firebase project configured

### Setup

```bash
git clone https://github.com/hd77alu/flutter_g2_final_project.git
cd flutter_g2_final_project
flutter pub get
flutter run
```

### Firebase Setup
1. Enable Anonymous and Google sign-in in Firebase Console under Authentication
2. Create Firestore Database in test mode
3. Place google-services.json in android/app/
4. Place GoogleService-Info.plist in ios/Runner/

---

## Git Branches

| Branch | Description |
|---|---|
| `feat/models` | Course, progress and accessibility models |
| `feat/firestore-service` | Extended FirestoreService with full CRUD |
| `feat/discover-bloc` | DiscoverBloc implementation |
| `feat/accessibility-bloc` | AccessibilityBloc implementation |
| `feat/discover-screen` | Discover screen UI and Firebase |
| `feat/accessibility-screen` | Accessibility Setup screen UI and Firebase |
| `fix/auth-navigation` | Firebase Auth integration and guest sign-in |
| `fix/routes-navigation` | Route updates and navigation fixes |
| `feat/share-course` | Native share functionality for courses |

---

## Navigation Flow

```
OutlookScreen
  └── Start here → AccessibilitySetupScreen
        └── Continue → SignUpScreen
              ├── Sign up with Google → CourseCompletionScreen
              └── Continue as Guest  → CourseCompletionScreen
                    └── Proceed → MentorshipHubScreen

OutlookScreen
  └── Lessons tile → DiscoverScreen
  └── Profile icon → ProfileScreen
        ├── My Skills → MySkillsScreen
        └── Preferences → PreferencesScreen
```

---

## License

This project was created for academic purposes at ALU.