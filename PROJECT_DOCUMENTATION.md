# SMRS Project Documentation

## Overview
**SMRS (Supermarket Staff Management System)** is a Flutter application designed to manage supermarket staff, specifically handling leaves, shifts, and administrative tasks.

## Tech Stack

### Core Framework
- **Flutter**: UI Toolkit (SDK >=3.10.0 <4.0.0)
- **Dart**: Programming Language

### State Management
- **Flutter Riverpod (v2.x)**: The project uses Riverpod for state management, specifically leveraging code generation (`@riverpod` annotation) for type safety and reduced boilerplate.
- **Riverpod Generator**: Used to automatically generate providers.

### Backend & Data
- **Firebase**:
  - **Auth**: User authentication.
  - **Firestore**: NoSQL Cloud Database for storing user data, leave requests, etc.
- **Shared Preferences**: For persisting local settings like Theme Mode.
- **Freezed & JSON Serializable**: For immutable data models and JSON serialization/deserialization.

### Routing
- **GoRouter**: For declarative routing and navigation handling.

### UI & Theming
- **Material 3**: Design system.
- **Google Fonts**: Custom typography.
- **Lucide Icons**: Icon pack.

## Project Structure

The project follows a **Feature-First Architecture**, where code is organized by features rather than by layer.

```
lib/
├── core/                   # Shared core application logic
│   ├── router/             # GoRouter configuration
│   └── theme/              # App theme and ThemeProvider
├── features/               # Application features
│   ├── admin/              # Admin-specific functionality
│   ├── auth/               # Authentication (Login, User models)
│   ├── configuration/      # App configuration
│   ├── dashboard/          # Main dashboard screens
│   ├── leaves/             # Leave management (Request, Approve, History)
│   └── settings/           # App settings
├── shared/                 # Shared widgets and utilities
├── firebase_options.dart   # Firebase configuration (generated)
└── main.dart               # Entry point
```

## State Management Details

The application uses **Riverpod** with the **Generator** syntax.

### Key Concepts
1.  **Providers**: Defined using `@riverpod` annotations.
    - Example: `ThemeController` in `core/theme/theme_provider.dart` manages the theme state.
2.  **ConsumerWidget**: Widgets extend `ConsumerWidget` to listen to providers via `WidgetRef`.
    - Example: `MyApp` in `main.dart` watches `themeControllerProvider` to rebuild when the theme changes.
3.  **Code Generation**:
    - Files ending in `.g.dart` are generated files.
    - You must run `flutter pub run build_runner watch` or `build` to generate these files after making changes to providers or models.

## Key Features

1.  **Authentication**: Handled via Firebase Auth, with users assigned roles (e.g., Staff, Manager, Admin) stored in Firestore.
2.  **Leave Management**:
    - Staff can apply for leaves.
    - Managers can approve/reject leaves.
3.  **Dynamic Theme**:
    - Users can toggle between Light/Dark modes and select seed colors.
    - Preferences are persisted locally using `SharedPreferences`.

## Setup & Running

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Generate Code**:
    ```bash
    dart run build_runner build -d
    ```
3.  **Run App**:
    ```bash
    flutter run
    ```
