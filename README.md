# 🎬 TMDB Movies App

A modern, responsive, and feature-rich Flutter movie application built using **BLoC Pattern**, **TMDB REST API**, and **Firebase** (Authentication & Cloud Firestore). Designed with a sleek dark-themed cinematic user interface inspired by Netflix and modern streaming platforms.

---

## 🌟 Key Features

- **Cinematic UI/UX**:
  - Immersive Dark Theme with high-contrast amber accents.
  - Dynamic **Featured Spotlight Banner** with smooth gradient masks.
  - Horizontal categorization: *Trending Now*, *Top Rated*, *In Theaters*, and *Upcoming Releases*.
- **Real-time Live Search**:
  - Instant movie search with 500ms debounce handling to minimize API requests.
  - Dedicated search state management isolated from the home feed.
- **Movie Details**:
  - Detailed overview, rating, release year, poster backdrop, and interactive action buttons.
- **Custom User Watchlists**:
  - 4 personalized lists per user: **Favorites**, **Watching**, **Watched**, and **Want to Watch**.
  - Real-time cloud sync powered by Cloud Firestore Streams.
- **User Authentication**:
  - Secure email/password authentication via Firebase Auth (Sign In, Sign Up, and Sign Out).
  - User-specific database isolation (each account maintains its own private watchlists).

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Backend & Cloud Services**:
  - **Firebase Authentication**: User identity & session management.
  - **Cloud Firestore**: Real-time cloud database.
- **API**: [The Movie Database (TMDB) API](https://www.themoviedb.org/documentation/api)
- **Networking & Caching**:
  - `http` for RESTful network calls.
  - `cached_network_image` for smooth, cached image loading.

---

## 📁 Project Structure

```text
lib/
├── bloc/
│   ├── movie_bloc.dart
│   ├── movie_event.dart
│   └── movie_state.dart
├── model/
│   └── movie.dart
├── Screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── movie_home_screen.dart
│   ├── movie_search_screen.dart
│   ├── movie_detail_screen.dart
│   └── my_lists_screen.dart
├── service/
│   ├── auth_service.dart
│   ├── movie_list_service.dart
│   └── tmdb_service.dart
└── main.dart