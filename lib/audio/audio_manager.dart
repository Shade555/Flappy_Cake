import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final ValueNotifier<bool> muted = ValueNotifier<bool>(false);
  AudioPlayer? _player;

  Future<void> init() async {
    _player ??= AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.loop);
    // ensure volume matches current muted state
    await _player!.setVolume(muted.value ? 0.0 : 1.0);
  }

  Future<void> playLoop() async {
    await init();
    try {
      // Check that asset exists and is non-empty before asking player to play it.
      try {
        final bd = await rootBundle.load('assets/audio/song.mp3');
        if (bd.lengthInBytes == 0) {
          if (kDebugMode) print('AudioManager: assets/audio/song.mp3 is empty; skipping play.');
          return;
        }
      } catch (e) {
        if (kDebugMode) print('AudioManager: failed to load asset assets/audio/song.mp3: $e');
        return;
      }

      if (kDebugMode) print('AudioManager: playing assets/audio/song.mp3 (loop)');
      await _player!.play(AssetSource('audio/song.mp3'));
    } catch (_) {}
  }

  Future<void> stop() async {
    await _player?.stop();
  }

  void setMuted(bool m) {
    muted.value = m;
    _player?.setVolume(m ? 0.0 : 1.0);
  }

  void toggleMute() {
    setMuted(!muted.value);
  }
}
