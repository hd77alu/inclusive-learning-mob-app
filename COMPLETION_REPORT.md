# Project Completion Report
**Inclusive Mobile Learning & Skills Platform for Persons with Disabilities in Rwanda**
**Flutter Group 2 — Final Project**

---

## Status: ✅ Complete — `flutter analyze` reports 0 issues

---

## What Was Built

### Screen 1 — Course Completion Screen
**File:** `lib/presentation/screens/course_completion_screen.dart`

- `StatelessWidget` — no animations, no controllers
- Flat solid background `Color(0xFF0D1B1E)`
- `Congratulations!` badge — solid teal (`#1AFFFF`), black text, `BorderRadius.circular(30)` pill, `elevation: 0`
- `Proceed` button — full-width, `StadiumBorder()`, cyan fill, black text, no glow
- Layout: `MainAxisAlignment.spaceEvenly` — badge centered, button near bottom, balanced spacing
- `try-catch` block on Proceed with red `SnackBar` on error, navigates to `/mentorship-hub` on success
- `FirebaseAuth.instance.currentUser` null-check guard — redirects to `/signup` if unauthenticated

---

### Screen 2 — Mentorship Hub Screen
**File:** `lib/presentation/screens/mentorship_hub_screen.dart`

- Flat solid background `Color(0xFF0D1B1E)`
- Solid teal (`#1AFFFF`) header bar:
  - Back arrow (black, left)
  - Subtitle `"Inclusive Learning Platform"` + title `"Mentorship Hub"` stacked (black text)
  - Circular profile icon (right, black on dark overlay)
- Rounded search bar (`BorderRadius.circular(30)`), fill `#1E2E32`, hint: `"Search mentors by specialty..."`, live filtering by name and specialty
- Horizontal scrollable filter chips (`All`, `Sign Language`, `Braille`):
  - Wired to `FilterMentors` BLoC event
  - Selected: solid teal, black bold text, no glow
  - Unselected: dark bg (`#1A2426`), grey text, dark border
  - `AnimatedContainer` transition (180ms)
- `BlocProvider` creates and provides `MentorshipBloc` to the widget tree
- `BlocBuilder<MentorshipBloc, MentorshipState>` handles three states:
  - `MentorshipLoading` → cyan `CircularProgressIndicator`
  - `MentorshipError` → red error message
  - `MentorshipLoaded` → `ListView` of `MentorCard` widgets
- Empty state: `"No mentors found."` text
- `FirebaseAuth.instance.currentUser` null-check guard
- `ListView` — no pixel overflow on 5.5"–6.7" screens

---

### Mentor Card Widget
**File:** `lib/presentation/widgets/mentor_card.dart`

- `StatelessWidget` — no animations
- `Container` with `borderRadius: 20`, no glow shadow, `Clip.antiAlias`
- `InkWell` with subtle cyan splash for tap interaction
- Image banner (150px height):
  - `Image.network(mentor.imageUrl, fit: BoxFit.cover)` — shows real photos
  - `errorBuilder` fallback — dark placeholder with faint person icon
- `ONLINE NOW` green badge overlay — top-left, small pill (font 9px, padding 8×3, dot 6px)
- Mentor name — bold white, 15px
- Role / specialty — teal (`#1AFFFF`), 12px
- Description — max 2 lines, grey, ellipsis overflow (shown only if non-empty)
- Tags — `_TagChip` widgets in a `Wrap` (shown only if non-empty)
- Bookmark icon — cyan when saved, grey when not — dispatches `ToggleBookmark` to BLoC
- Darker action strip (`#1F2E31`) at bottom with 3 evenly spaced circular buttons:
  - Message, Call, Video — cyan icons, `InkWell` splash, label below

---

### BLoC — Mentorship
**File:** `lib/blocs/mentorship_bloc.dart`

| Event | Description |
|---|---|
| `LoadMentors` | Starts streaming mentors from Firestore via `emit.forEach` |
| `FilterMentors(filter)` | Updates `_filter`, re-emits filtered mentor list |
| `ToggleBookmark(userId, mentorId, isBookmarked)` | Calls bookmark or removeBookmark on service, updates state |

| State | Description |
|---|---|
| `MentorshipLoading` | Initial / fetching state |
| `MentorshipLoaded(mentors, bookmarkedIds, selectedFilter)` | Filtered mentor list, bookmarked IDs, active filter label |
| `MentorshipError(message)` | Error string for display |

- `_filtered()` — filters `_allMentors` by tag or specialty match against `_filter`

---

### Data Layer

#### Mentor Model
**File:** `lib/data/models/mentor_model.dart`

| Field | Type | Default | Description |
|---|---|---|---|
| `id` | `String` | required | Firestore document ID |
| `name` | `String` | required | Mentor display name |
| `specialty` | `String` | required | Role shown in teal on card |
| `isOnline` | `bool` | required | Controls ONLINE NOW badge |
| `imageUrl` | `String` | `''` | Network photo URL for banner |
| `description` | `String` | `''` | Short bio, max 2 lines on card |
| `tags` | `List<String>` | `[]` | Specialty tags shown as chips |

- `fromFirestore(DocumentSnapshot)` factory constructor included
- `imageUrl`, `description`, `tags` are optional — card handles missing values gracefully

#### Firestore Service
**File:** `lib/data/services/firestore_service.dart`

| Method | Returns | Description |
|---|---|---|
| `getMentors()` | `Stream<List<MentorModel>>` | Live stream from `mentors` collection |
| `getBookmarks(userId)` | `Stream<List<String>>` | Live stream of saved mentor IDs |
| `bookmarkMentor(userId, mentorId)` | `Future<void>` | Creates `users/{uid}/savedMentors/{mentorId}` |
| `removeBookmark(userId, mentorId)` | `Future<void>` | Deletes `users/{uid}/savedMentors/{mentorId}` |

---

### Stub Screens (Scaffolded — ready for implementation)

| File | Class | Status |
|---|---|---|
| `app_outlook_screen.dart` | `OutlookScreen` | Stub — Get Started navigates to `/signup` |
| `my_skills_screen.dart` | `MySkillsScreen` | Stub — placeholder scaffold |
| `discover_screen.dart` | `DiscoverScreen` | Stub — placeholder scaffold |
| `accessibility_setup_screen.dart` | `AccessibilitySetupScreen` | Stub — placeholder scaffold |
| `mentor_profile_screen.dart` | `MentorProfileScreen` | Stub — placeholder scaffold |

---

### Pre-existing Screens (Untouched)

| File | Class | Notes |
|---|---|---|
| `sign_up_screen.dart` | `SignUpScreen` | Google Sign-In + Anonymous guest sign-in |
| `profile_screen.dart` | `ProfileScreen` | User info, logout, links to Preferences and Skills |
| `preferences_screen.dart` | `PreferencesScreen` | Dark mode, notifications, language via SharedPreferences |

---

## Project File Structure

```
lib/
├── main.dart                               ✅ App entry, Firebase init, named routes
├── firebase_options.dart                   ✅ Firebase config (auto-generated)
├── blocs/
│   ├── mentorship_bloc.dart                ✅ Complete — Events, States, BLoC, filter logic
│   ├── accessibility_bloc.dart             ⬜ Scaffolded
│   ├── discover_bloc.dart                  ⬜ Scaffolded
│   └── skills_bloc.dart                    ⬜ Scaffolded
├── data/
│   ├── models/
│   │   ├── mentor_model.dart               ✅ Complete
│   │   ├── course_model.dart               ⬜ Scaffolded
│   │   ├── course_progress_model.dart      ⬜ Scaffolded
│   │   ├── accessibility_model.dart        ⬜ Scaffolded
│   │   └── skill_model.dart                ⬜ Scaffolded
│   └── services/
│       └── firestore_service.dart          ✅ Complete
└── presentation/
    ├── screens/
    │   ├── course_completion_screen.dart   ✅ Complete
    │   ├── mentorship_hub_screen.dart      ✅ Complete
    │   ├── sign_up_screen.dart             ✅ Complete (pre-existing)
    │   ├── profile_screen.dart             ✅ Complete (pre-existing)
    │   ├── preferences_screen.dart         ✅ Complete (pre-existing)
    │   ├── app_outlook_screen.dart         ⬜ Stub
    │   ├── discover_screen.dart            ⬜ Stub
    │   ├── my_skills_screen.dart           ⬜ Stub
    │   ├── accessibility_setup_screen.dart ⬜ Stub
    │   └── mentor_profile_screen.dart      ⬜ Stub
    └── widgets/
        └── mentor_card.dart                ✅ Complete
```

---

## Firestore Collections Required

### `mentors` collection
Each document should have:
```json
{
  "name": "Jean Bosco N.",
  "specialty": "Kinyarwanda Sign Language Expert",
  "isOnline": true,
  "imageUrl": "https://your-image-url.com/photo.jpg",
  "description": "Helping learners communicate effectively through sign language.",
  "tags": ["Sign Language", "Job Coaching"]
}
```
- `imageUrl`, `description`, `tags` are optional
- Filter chips match against `tags` array and `specialty` field

### `users/{uid}/savedMentors/{mentorId}` — bookmark CRUD
```json
{
  "savedAt": "<server timestamp>"
}
```

---

## App Routes

| Route | Screen | Auth Required |
|---|---|---|
| `/` | `OutlookScreen` | No |
| `/signup` | `SignUpScreen` | No |
| `/course-completion` | `CourseCompletionScreen` | Yes |
| `/mentorship-hub` | `MentorshipHubScreen` | Yes |
| `/profile` | `ProfileScreen` | Yes |
| `/skills` | `MySkillsScreen` | Yes |
| `/preferences` | `PreferencesScreen` | Yes |
| `/discover` | `DiscoverScreen` | Yes |
| `/accessibility-setup` | `AccessibilitySetupScreen` | Yes |

---

## Assignment Requirements Checklist

| Requirement | Status |
|---|---|
| Flat dark background `#0D1B1E` (no gradient) | ✅ |
| Primary accent `#1AFFFF` throughout | ✅ |
| Material 3 (`useMaterial3: true`) | ✅ |
| Rounded corners everywhere (20–30px) | ✅ |
| No glow effects — clean flat design | ✅ |
| Responsive layout — no overflow on 5.5"–6.7" | ✅ |
| `MediaQuery` / `Expanded` / `Flexible` for sizing | ✅ |
| Clean widget separation — UI vs data | ✅ |
| BLoC state management (`flutter_bloc`) | ✅ |
| Loading / Success / Error states via BLoC | ✅ |
| Firestore fetch via BLoC → Service (not direct in UI) | ✅ |
| Filter chips wired to `FilterMentors` BLoC event | ✅ |
| CRUD — bookmark / remove bookmark mentor | ✅ |
| `FirebaseAuth.instance.currentUser` null-check on both screens | ✅ |
| `try-catch` with `SnackBar` on Proceed button | ✅ |
| `StadiumBorder()` on Proceed button | ✅ |
| `Congratulations!` solid teal pill badge, black text | ✅ |
| Solid teal header bar on Mentorship Hub | ✅ |
| Subtitle `"Inclusive Learning Platform"` in header | ✅ |
| Profile icon in header | ✅ |
| Rounded search bar — `"Search mentors by specialty..."` | ✅ |
| Mentor Card — `Image.network` real photo with fallback | ✅ |
| Mentor Card — `ONLINE NOW` small green badge overlay | ✅ |
| Mentor Card — teal specialty text, description, tags | ✅ |
| Mentor Card — 3 circular action buttons (Message, Call, Video) | ✅ |
| `InkWell` splash on card and action buttons | ✅ |
| `ListView` / scrollable mentor list | ✅ |
| `flutter analyze` — 0 issues | ✅ |

---

*Generated: Flutter Group 2 Final Project — Inclusive Learning Platform*
REMOVE / FIX

Gradient background

Dark heavy card

Empty avatar

Extra spacing

🟡 ADD (IMPORTANT)

Image (real photo)

Role text

Description

Tag chips

Online badge

🟢 KEEP

Structure

Search/filter

BLoC