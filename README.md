# 🎵 MusicLotm

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/State_Management-GetX-8A2BE2?style=for-the-badge)
![Audio Engine](https://img.shields.io/badge/Audio_Engine-just__audio-FF5722?style=for-the-badge)
![Database](https://img.shields.io/badge/Local_Storage-Hive-F9A825?style=for-the-badge)
![License](https://img.shields.io/badge/License-Portfolio%20%2F%20Showcase-blue?style=for-the-badge)

**A high-performance, offline-first, neumorphic music player for Android.**  
Engineered with fluid 60 FPS audio visualizers, background playback, ID3 tag editing, and a tactile neumorphic design language.

[Key Features](#-key-features) • [What's New in v1.2.0](#-whats-new-in-v120) • [Architecture](#-architecture--tech-stack) • [Installation](#-installation--setup) • [Screenshots](#-screenshots)

</div>

---

## ✨ Highlights

- 🎧 **Offline-First Excellence**: Instant scanning and playback of local storage tracks with zero internet required.
- 🎨 **Tactile Neumorphic Design**: Custom soft-shadow surfaces, recessed buttons, and smooth responsive animations built with `flutter_screenutil`.
- 📊 **60 FPS Visualizer Engine**: Native real-time frequency analysis powered by our custom in-tree `just_audio` engine with zero microphone permissions, featuring 3 visual styles (Radial Bars, Liquid Wave, and Eclipse Nova).
- 🎛️ **Floating Mini-Player**: Persistent player pinned across library, playlist, and favorite tabs with live progress scrubbing.
- 🏷️ **Built-in Tag Editor**: Edit ID3 metadata (Song title, Artist, Album, Genre) locally with instantaneous state synchronization.
- ⏱️ **Smart Sleep Timer**: Battery-preserving timer with preset chips and a custom slider that fades out and terminates playback gracefully.
- 🔒 **100% Privacy & Zero Ads**: No telemetry, no third-party tracking, and no ads. Playlists, favorites, and settings stay strictly on-device via Hive.

---

## 🚀 What's New in v1.2.0

### 1. 🌊 Isolated 60 FPS Visualizer Engine
- Re-architected visualizer rendering using a dedicated, isolated GetX controller and `RepaintBoundary` to prevent full player rebuilds during high-frequency audio polling.
- **3 Visualizer Modes**:
  - **Radial Bars**: Symmetrical pulsating frequency rings radiating from the album artwork.
  - **Liquid Wave**: Smooth sine-interpolated waveforms flowing dynamically with audio amplitude.
  - **Eclipse Nova**: Modern high-energy radial starburst reactive to bass and mid frequencies.
- **Visualizer Customization Sheet**: Real-time slider controls for sensitivity, visualizer bar/wave color customization, and instant style switching.

### 2. 🎚️ Persistent Neumorphic Mini-Player
- Floating docked player above the bottom navigation bar across all navigation destinations (`Playlist`, `Favorite`, `Contact`).
- Interactive mini-scrubber bar showing buffered and elapsed song progress.
- Quick playback controls (Play/Pause, Skip Next, Favorite toggle) with smooth sheet expansion to the full player screen.

### 3. 🏷️ Metadata & ID3 Tag Editor
- Accessible directly from song tile action sheets.
- Enables updating song title, artist, album, and genre tags directly into file metadata and Hive persistence.

### 4. 🧹 Clean Code & Performance Refactor
- 100% strict adherence to the application design system and theme tokens across all dialogs, bottom sheets, and buttons.
- Purged all legacy and redundant components (`customappbar.dart`, `timer_widget.dart`, `timeandshufell.dart`).
- Standardized directory naming (`lib/core/middleware/`).
- Fully optimized Android R8 ProGuard build rules for smaller, faster, release-ready APK builds.
- Clean analysis: `flutter analyze` reports **0 errors, 0 warnings, 0 issues**.

---

## 🛠️ Architecture & Tech Stack

```
├── packages/
│   └── just_audio/     # Custom in-tree audio engine with native ExoPlayer TeeAudioProcessor FFT tap
├── lib/
│   ├── controller/     # GetX controllers (SongsController, VisualizerController, etc.)
│   ├── core/
│   │   ├── Widget/     # Reusable Neumorphic widgets, Mini-Player, Visualizers, Sheets
│   │   ├── constant/   # App colors, theme data, typography, dimensions
│   │   ├── function/   # Audio conversion, sorting, formatters, permission handlers
│   │   ├── middleware/ # Navigation & routing guards
│   │   ├── model/      # Song, Playlist, and Favorite data models
│   │   └── routes/     # Centralized named routing
│   └── view/           # Application views (Player, Playlists, Favorites, Navigation)
```

| Component | Technology | Description |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) | UI toolkit for cross-platform applications |
| **Language** | [Dart](https://dart.dev) | Strongly-typed object-oriented language |
| **State Management** | [GetX](https://pub.dev/packages/get) | High-performance reactive state management & dependency injection |
| **Audio Engine** | [just_audio](https://pub.dev/packages/just_audio) & [audio_service](https://pub.dev/packages/audio_service) | Low-latency audio playback with lockscreen & notification support |
| **Visualizer DSP** | [Custom just_audio (In-Tree)](packages/just_audio) | Native ExoPlayer `TeeAudioProcessor` PCM buffer tap (32 frequency bands, zero mic permission required) |
| **Local Storage** | [Hive](https://pub.dev/packages/hive) | Ultra-fast lightweight key-value database |
| **Tag Editing** | [audiotags](https://pub.dev/packages/audiotags) | Native ID3 metadata reader and writer |
| **UI Scaling** | [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) | Multi-device responsive adaptation |

---

## 📱 Screenshots

> *Add your app screenshots here*

| Now Playing & Visualizer | Library & Mini-Player | Visualizer Settings | Sleep Timer |
|:---:|:---:|:---:|:---:|
| *(Add screenshot)* | *(Add screenshot)* | *(Add screenshot)* | *(Add screenshot)* |

---

## 📦 Installation & Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19+ recommended)
- [Android SDK](https://developer.android.com/studio) (API 34+ recommended)
- Java 17+

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/laithmh/MusicLotm.git
   cd MusicLotm
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run in debug mode:**
   ```bash
   flutter run
   ```

4. **Build release APK:**
   ```bash
   flutter build apk --release
   ```
   The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🔒 Permissions & Privacy

MusicLotm strictly requests only the minimal permissions necessary for offline playback:
- `READ_MEDIA_AUDIO` / `READ_EXTERNAL_STORAGE`: To index and play audio files stored locally on the device.
- `FOREGROUND_SERVICE` & `WAKE_LOCK`: To allow uninterrupted playback and media notification controls when the app is in the background or screen is locked.
- **Zero Microphone Permissions**: Unlike traditional visualizer apps that require `RECORD_AUDIO`, our custom in-tree `just_audio` engine taps directly into the decoded ExoPlayer PCM audio buffer via a native `TeeAudioProcessor`. No microphone access is ever requested!

No network permissions are used to upload personal data. Your listening history and playlists remain 100% private and on-device.

---

## 📄 License

This project is licensed under a custom **Portfolio & Showcase License**. You are welcome to view, download, and run the code for educational, review, or evaluation purposes. Commercial monetization, rebranding, and unauthorized app-store redistribution are prohibited. See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Laith**  
*Flutter Developer & UI/UX Enthusiast*  
- GitHub: [@laithmh](https://github.com/laithmh)
