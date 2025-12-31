import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer player = AudioPlayer();

  AudioManager._internal() {
    // Set player mode to allow background play
    player.setReleaseMode(ReleaseMode.stop);
  }

  // 🔥 Music STOP method
  Future<void> stopAudio() async {
    try {
      await player.stop();
      await player.dispose();
    } catch (e) {
      // Silent error handling
    }
  }

  // 🔥 Pause Audio
  Future<void> pauseAudio() async {
    try {
      await player.pause();
    } catch (e) {
      // Silent error handling
    }
  }

  // 🔥 Resume Audio
  Future<void> resumeAudio() async {
    try {
      await player.resume();
    } catch (e) {
      // Silent error handling
    }
  }

  // 🔥 Check if playing
  bool isPlaying() {
    return player.state == PlayerState.playing;
  }

  // 🔥 Get current state
  PlayerState getState() {
    return player.state;
  }
}