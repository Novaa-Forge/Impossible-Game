import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Controller that manages all audio functionality within the game
/// including sfx and music
class AudioController with ChangeNotifier {
  // flag to mute and un-mute audio
  bool audioEnabled = true;

  // Audioplayer responsible for background music in the game
  final backgroundMusicPlayer = AudioPlayer();

  // Audioplayer responsible for all sound effects played within the game
  static final sfxPlayer = AudioPlayer();

  /// toggles background music audio front mute/unmute
  void toggleAudio() {
    audioEnabled = !audioEnabled;
    notifyListeners();
  }

  /// plays fixed background music track
  Future<void> playBackgroundMusic() async {
    try {
      backgroundMusicPlayer.stop();
      await backgroundMusicPlayer.setAsset(
        "assets/audio/calm-game-background.mp3",
      );
      backgroundMusicPlayer.setVolume(0.3);
      backgroundMusicPlayer.setLoopMode(
        LoopMode.one,
      ); // ensures music loops in the game at the end of the track
      backgroundMusicPlayer.play();
    } catch (e) {
      print("Error playing background music: $e");
    }
  }

  /// plays sound effects depending on the [sfxType] passed
  static Future<void> playSfx(SfxType sfxType) async {
    switch (sfxType) {
      case (SfxType.complete):
        await sfxPlayer.setAsset("assets/audio/level_complete_audio.mp3");
        break;
      case (SfxType.positive):
        await sfxPlayer.setAsset("assets/audio/positive_beep.mp3");
        break;
      case (SfxType.negative):
        await sfxPlayer.setAsset("assets/audio/negative_beeps.mp3");
        break;
    }
    sfxPlayer.play();
  }
}

/// enum that represents different types of sound effects in the game
/// [positive] : good activity performed (e.g., green tile selected)
/// [negative] : bad activity performed (e.g., red tile selected)
/// [complete] : key milestone achieved (e.g., level completed)
enum SfxType { positive, negative, complete }
