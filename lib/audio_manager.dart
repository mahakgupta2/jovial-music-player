import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer player = AudioPlayer();

  AudioManager._internal();

  // 🔥 Music STOP method
  Future<void> stopAudio() async {
    try {
      await player.stop();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }
}
