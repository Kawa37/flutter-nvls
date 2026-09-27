# Novels (flutter-nvls)

A Flutter Android app for reading a personal, bundled library of novels/light novels — offline, chapter by chapter, with reading progress, bookmarks, and history tracking.

## Features

- **Library grid** — browse your novel collection as cover-art cards, reorderable by "last opened."
- **Continue reading** — floating action button jumps straight back into the last-read novel.
- **Chapter reader** — scrollable text view with:
  - Automatic scroll-position saving/restoring per chapter
  - Auto-marks a chapter "read" once you scroll to the end
  - Bookmarking individual chapters
  - Swipe left/right to move between chapters
- **History** — list of recently read novels with quick resume, and a "delete all" action.
- **Hide/unhide novels** — multi-select novels in the library to hide them from the main view (double-tap the title to toggle the hidden view).
- **Light/Dark theme** toggle, persisted across launches.
- **Local storage** — reading progress, bookmarks, history, and sort order are persisted with [Hive](https://pub.dev/packages/hive); the app also mirrors novel metadata to `/storage/emulated/0/Novels/data.json` on the device (requires storage permission on Android).

## Tech Stack

- **Flutter** (Dart SDK `^3.13.1`)
- **Hive** / **hive_flutter** — local NoSQL key-value storage
- **permission_handler** — Android storage permissions
- **flutter_slidable**, **expandable_text** — UI components
- **flutter_launcher_icons** — custom app icon generation

## Project Structure

```
lib/
├── main.dart        # App entry point, theme setup, bottom navigation
├── home.dart         # Library page: grid of novels, storage permission/file I/O
├── chaplist.dart      # Chapter list for a selected novel
├── reading.dart       # Chapter reader: scroll position, bookmarks, history
├── history.dart       # Reading history list
├── settings.dart      # Theme toggle
└── utils.dart         # Shared helpers

assets/
├── data.json          # Generated metadata for all novels (id, title, chapter count, description)
├── gen-data.py         # Script that scans assets/nvls/ and (re)builds data.json
├── nvls/               # One folder per novel, containing chapter .txt files + cover_<id>.webp
├── fonts/              # Bundled JetBrains Mono NL Nerd Font
└── icon/               # App icon source
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.13.1`)
- Android SDK / an Android device or emulator (this app targets Android; iOS/web scaffolding exists but is not the primary target)

### Setup

```bash
git clone https://github.com/Kawa37/flutter-nvls.git
cd flutter-nvls
flutter pub get
```

### Adding novels

Each novel lives in its own folder under `assets/nvls/<novel_id>/`, containing:
- Numbered chapter files: `1.txt`, `2.txt`, …
- A cover image: `cover_<novel_id>.webp`
- (optional) `description.csv` with a short blurb

After adding/removing novels, regenerate the metadata file:

```bash
python assets/gen-data.py
```

Then make sure each new novel folder is listed under `flutter.assets` in `pubspec.yaml` so Flutter bundles it.

### Run

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk
```

## Storage & Permissions

On first launch, the app requests `MANAGE_EXTERNAL_STORAGE` (Android) to create a `Novels` folder at `/storage/emulated/0/Novels` and write a copy of the novel metadata there. Reading progress, bookmarks, sort order, and history are stored locally via Hive and do not require this permission.

## License

No license specified.
