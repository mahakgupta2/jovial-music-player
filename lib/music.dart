import  'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';

class MusicPage extends StatefulWidget {
  final Song song;
  const MusicPage({super.key, required this.song});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  double _volume = 1.0;
  bool _isLooping = false;
  bool _showVolumeSlider = false;

  bool get _playing => _state == PlayerState.playing;

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });

    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
    });

    _player.onPlayerComplete.listen((_) {
      if (_isLooping) {
        _player.seek(Duration.zero);
        _player.resume();
      } else {
        setState(() => _position = _duration);
      }
    });

    _player.play(UrlSource(widget.song.audioUrl));
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggle() => _playing ? _player.pause() : _player.resume();

  void _seekRelative(int secs) =>
      _player.seek(_position + Duration(seconds: secs));

  void _toggleLoop() {
    setState(() => _isLooping = !_isLooping);
  }

  void _setVolume(double value) {
    setState(() => _volume = value);
    _player.setVolume(_volume);
  }

  void _toggleVolumeSlider() {
    setState(() => _showVolumeSlider = !_showVolumeSlider);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.song;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(s.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Album art
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  s.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.title,
              style: const TextStyle(
                  fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            Text(s.subtitle, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(_fmt(_position),
                      style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  Text(_fmt(_duration),
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Slider(
              value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
              max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
              activeColor: Colors.amber,
              inactiveColor: Colors.white24,
            ),
            const SizedBox(height: 10),

            // Controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Loop toggle
                IconButton(
                  icon: Icon(
                    _isLooping ? Icons.repeat : Icons.repeat_one,
                    color: Colors.white,
                  ),
                  onPressed: _toggleLoop,
                ),

                // Rewind 10s
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 30),
                  onPressed: () => _seekRelative(-10),
                ),

                // Play/pause button
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.amber,
                  child: IconButton(
                    icon: Icon(
                      _playing ? Icons.pause : Icons.play_arrow,
                      size: 36,
                      color: Colors.black,
                    ),
                    onPressed: _toggle,
                  ),
                ),

                // Forward 10s
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white, size: 30),
                  onPressed: () => _seekRelative(10),
                ),

                // Volume icon (toggle slider)
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  onPressed: _toggleVolumeSlider,
                ),
              ],
            ),

            // Volume slider (toggleable)
            if (_showVolumeSlider)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Slider(
                  value: _volume,
                  onChanged: _setVolume,
                  min: 0,
                  max: 1,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.white24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
