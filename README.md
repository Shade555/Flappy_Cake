# flappy_cake — Cousins Birthday

`flappy_cake` (Cousins Birthday) is a small Flappy Bird–style game built with Flutter and Flame. The player controls a cake that must fly through candle obstacles. The project is designed for quick iteration and learning: it includes Flame components, overlays for menus and game-over screens, persistent high-score storage, simple audio support, and build scripts to produce an APK.

## Highlights
- Flame-based game loop and components
- Cake player sprite (with fallback drawing)
- Candle obstacles (pipe sprites) and scalable gaps
- Ground collision that triggers game over
- Menu and Game Over overlays with persistent best score (`shared_preferences`)
- Fixed background gradient with centered celebratory text
- Looping background music and mute/unmute controls
- Firework animation overlay when starting a run
- Simple build and packaging flow for APK output

## Project layout
- `lib/`
	- `main.dart` — app entry, `GameWidget`, and overlay builders
	- `game/flappy_game.dart` — main `FlameGame` implementation
	- `components/` — `bird.dart`, `pipe_pair.dart`, `ground.dart`, `background.dart`, etc.
	- `audio/` — simple `AudioManager` for looping music and mute state
- `assets/`
	- `assets/images/` — `candle.png`, `cake.png`
	- `assets/audio/` — `song.mp3` (replace with a real audio file)
- `pubspec.yaml` — dependencies and asset declarations
- `build/` — build outputs (APK, intermediates)

## Getting started (development)
1. Ensure Flutter is installed and on your `PATH`.
2. From the project root, fetch packages and run on a device/emulator:
```bash
flutter pub get
flutter run
```

On Windows, you can target a specific device with:
```powershell
flutter run -d <device-id>
```

## Assets
- Place images in `assets/images/`:
	- `assets/images/candle.png` — candle sprite used for obstacles
	- `assets/images/cake.png` — cake sprite used for the player and launcher icon
- Place audio in `assets/audio/song.mp3` and confirm it is non-empty. After adding assets run:
```bash
flutter pub get
```

If an asset fails to load, check the debug console for messages indicating the missing path.

## Build APK (release)
1. Create a release APK:
```bash
flutter build apk --release
```
2. Output path (example):
- `build/app/outputs/flutter-apk/app-release.apk`

## Installing the APK
- Install locally via `adb`:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
- You can send the APK via WhatsApp (attach as Document) or upload it to cloud storage and share the link. If WhatsApp blocks the APK, compress it to a `.zip` and send the zip.

## Gameplay & Controls
- Tap anywhere on screen to flap the cake.
- From the main menu use Start to begin — a short firework overlay plays first.
- On game over you can Retry or return to Menu. The best score is saved across runs.
- Mute/unmute background music from the Menu or Game Over overlays.

## Tuning collisions and visuals
- Collision insets are configurable in `lib/components/bird.dart` and `lib/components/pipe_pair.dart`.
- If collisions feel off, tweak the inset percentage values and rebuild.

## App name and icons
- The app is identified as `flappy_cake` in this repository. Launcher icons are generated via `flutter_launcher_icons` using `assets/images/cake.png` by default; update `pubspec.yaml` and re-run the icon builder to refresh icons.

## Troubleshooting
- Images not appearing: ensure the exact path exists and run `flutter pub get`.
- Audio not playing: confirm `assets/audio/song.mp3` is non-empty and declared under `flutter.assets` in `pubspec.yaml`.
- Build errors: run `flutter analyze` and inspect console logs for missing imports or incompatible plugin versions.

## Notes
This repository is intended as a learning/demo project. Replace placeholder art and audio with real assets for a polished experience. If you plan to publish to the Play Store, set up proper signing and produce an AAB.

---
`flappy_cake` — have fun, and happy celebrating!
