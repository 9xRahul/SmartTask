# Smart Task Manager

An offline-first task management mobile application built with Flutter, BLoC state management, Clean Architecture, Hive local storage, and Firebase.

## Features

- **Authentication**: Email and password registration and login via Firebase Authentication.
- **Offline First**: Instant local read and write operations powered by Hive, with automatic background synchronization upon network reconnection.
- **Task Management**: Create, view, edit, and delete tasks with priority levels, status filters, search, and sorting.
- **State Management**: Predictable state management using BLoC pattern with layer separation.
- **Theme Support**: Dynamic light and dark mode support.

## Architecture

The project follows Clean Architecture principles:

- `lib/core`: Shared utilities, constants, theme configurations, error handling, and networking.
- `lib/features/auth`: User authentication and session management.
- `lib/features/profile`: User profile and theme settings.
- `lib/features/task`: Task data sources, repository, domain models, and presentation UI.

## Getting Started

### Prerequisites

- Flutter SDK (3.13.0 or later)
- Android Studio or VS Code with Flutter extension
- Firebase project configuration

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/9xRahul/SmartTask.git
   cd SmartTask
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Place `google-services.json` in the `android/app/` directory.
   - Enable Email/Password authentication in the Firebase console.

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter_bloc` & `equatable` - State management
- `get_it` - Dependency injection
- `hive` & `hive_flutter` - Local persistent storage
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Backend services
- `connectivity_plus` - Network connectivity monitoring
- `dio` - HTTP client
