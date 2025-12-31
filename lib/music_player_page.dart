import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';
import 'dart:async';

// Global player state to keep music playing when minimized
class GlobalMusicPlayer {
  static final GlobalMusicPlayer instance = GlobalMusicPlayer._();
  GlobalMusicPlayer._();

  AudioPlayer? _audioPlayer;
  Song? currentSong;
  List<Song> playlist = [];
  int currentIndex = 0;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isRepeat = false;
  bool isShuffle = false;
  List<Song> originalPlaylist = []; // Store original order for unshuffle

  // Stream controllers for state changes
  final _stateController = StreamController<bool>.broadcast();
  Stream<bool> get onPlayingStateChanged => _stateController.stream;

  AudioPlayer get audioPlayer {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  void notifyStateChanged() {
    _stateController.add(isPlaying);
  }

  void toggleShuffle(Song currentSong) {
    isShuffle = !isShuffle;

    if (isShuffle) {
      // Save original playlist
      originalPlaylist = List.from(playlist);

      // Find current song index
      int currentSongIndex = playlist.indexWhere((s) => s.audioUrl == currentSong.audioUrl);

      // Remove current song from list
      if (currentSongIndex != -1) {
        playlist.removeAt(currentSongIndex);
      }

      // Shuffle remaining songs
      playlist.shuffle();

      // Put current song at the beginning
      if (currentSongIndex != -1) {
        playlist.insert(0, currentSong);
      }

      // Update current index
      currentIndex = 0;
    } else {
      // Restore original playlist
      if (originalPlaylist.isNotEmpty) {
        // Find current song in original playlist
        int originalIndex = originalPlaylist.indexWhere((s) => s.audioUrl == currentSong.audioUrl);

        playlist = List.from(originalPlaylist);
        currentIndex = originalIndex != -1 ? originalIndex : 0;
        originalPlaylist.clear();
      }
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _stateController.close();
  }
}

class MusicPlayerPage extends StatefulWidget {
  final Song song;
  final List<Song> playlist;
  final int currentIndex;

  const MusicPlayerPage({
    super.key,
    required this.song,
    required this.playlist,
    required this.currentIndex,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final _player = GlobalMusicPlayer.instance;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completeSubscription;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    super.dispose();
  }

  void _initPlayer() async {
    // Cancel existing subscriptions first
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();

    // Check if we need to play a new song
    // Using audioUrl as unique identifier (change to .id if your Song model has id field)
    bool needsToPlayNewSong = _player.currentSong?.audioUrl != widget.song.audioUrl;

    // Update playlist info
    _player.playlist = widget.playlist;
    _player.currentIndex = widget.currentIndex;
    _player.currentSong = widget.song;

    // Setup listeners
    _playerStateSubscription = _player.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _player.isPlaying = state == PlayerState.playing;
        });
        _player.notifyStateChanged();
      }
    });

    _durationSubscription = _player.audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _player.duration = newDuration;
        });
      }
    });

    _positionSubscription = _player.audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _player.position = newPosition;
        });
      }
    });

    // Song complete listener
    _completeSubscription = _player.audioPlayer.onPlayerComplete.listen((event) async {
      if (_player.isRepeat) {
        // Repeat current song
        await _player.audioPlayer.seek(Duration.zero);
        await _player.audioPlayer.resume();
      } else {
        // Auto play next song
        _playNext();
      }
    });

    // Play the new song if it's different from currently playing
    if (needsToPlayNewSong && widget.song.audioUrl.isNotEmpty) {
      await _player.audioPlayer.stop();
      await _player.audioPlayer.play(UrlSource(widget.song.audioUrl));
    }
  }

  void _playPause() async {
    if (_player.isPlaying) {
      await _player.audioPlayer.pause();
    } else {
      await _player.audioPlayer.resume();
    }
  }

  void _seekForward() async {
    final newPosition = _player.position + const Duration(seconds: 10);
    if (newPosition < _player.duration) {
      await _player.audioPlayer.seek(newPosition);
    } else {
      await _player.audioPlayer.seek(_player.duration);
    }
  }

  void _seekBackward() async {
    final newPosition = _player.position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await _player.audioPlayer.seek(newPosition);
    } else {
      await _player.audioPlayer.seek(Duration.zero);
    }
  }

  void _playNext() async {
    if (_player.currentIndex < _player.playlist.length - 1) {
      if (mounted) {
        setState(() {
          _player.currentIndex++;
          _player.currentSong = _player.playlist[_player.currentIndex];
        });
      }
      await _player.audioPlayer.stop();
      if (_player.currentSong!.audioUrl.isNotEmpty) {
        await _player.audioPlayer.play(UrlSource(_player.currentSong!.audioUrl));
      }
    } else {
      // Reached end of playlist - stop playing
      await _player.audioPlayer.stop();
      if (mounted) {
        setState(() {
          _player.isPlaying = false;
        });
      }
    }
  }

  void _playPrevious() async {
    if (_player.currentIndex > 0) {
      if (mounted) {
        setState(() {
          _player.currentIndex--;
          _player.currentSong = _player.playlist[_player.currentIndex];
        });
      }
      await _player.audioPlayer.stop();
      if (_player.currentSong!.audioUrl.isNotEmpty) {
        await _player.audioPlayer.play(UrlSource(_player.currentSong!.audioUrl));
      }
    }
  }

  void _toggleRepeat() {
    setState(() {
      _player.isRepeat = !_player.isRepeat;
    });
  }

  void _toggleShuffle() {
    setState(() {
      _player.toggleShuffle(_player.currentSong!);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Bar with minimize button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 32),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Album Art
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _player.currentSong?.imageUrl ?? '',
                          height: 280,
                          width: 280,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 280,
                              width: 280,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.music_note,
                                  size: 100, color: Colors.white54),
                            );
                          },
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Song Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Text(
                            _player.currentSong?.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _player.currentSong?.subtitle ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                            ),
                            child: Slider(
                              value: _player.duration.inSeconds > 0
                                  ? _player.position.inSeconds
                                  .toDouble()
                                  .clamp(0.0, _player.duration.inSeconds.toDouble())
                                  : 0.0,
                              max: _player.duration.inSeconds.toDouble() > 0
                                  ? _player.duration.inSeconds.toDouble()
                                  : 1.0,
                              onChanged: (value) async {
                                await _player.audioPlayer
                                    .seek(Duration(seconds: value.toInt()));
                              },
                              activeColor: Colors.orange,
                              inactiveColor: Colors.white24,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_player.position),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_player.duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Controls - Main Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous Button
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white, size: 36),
                            onPressed:
                            _player.currentIndex > 0 ? _playPrevious : null,
                          ),

                          const SizedBox(width: 8),

                          // Backward 10s
                          IconButton(
                            icon: const Icon(Icons.replay_10,
                                color: Colors.white, size: 32),
                            onPressed: _seekBackward,
                          ),

                          const SizedBox(width: 12),

                          // Play/Pause Button
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _player.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 38,
                              ),
                              onPressed: _playPause,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Forward 10s
                          IconButton(
                            icon: const Icon(Icons.forward_10,
                                color: Colors.white, size: 32),
                            onPressed: _seekForward,
                          ),

                          const SizedBox(width: 8),

                          // Next Button
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white, size: 36),
                            onPressed: _player.currentIndex <
                                _player.playlist.length - 1
                                ? _playNext
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Secondary Controls Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Shuffle
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: _player.isShuffle
                                  ? Colors.orange
                                  : Colors.white70,
                              size: 24,
                            ),
                            onPressed: _toggleShuffle,
                          ),

                          // Repeat Button
                          IconButton(
                            icon: Icon(
                              _player.isRepeat
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              color: _player.isRepeat
                                  ? Colors.orange
                                  : Colors.white70,
                              size: 24,
                            ),
                            onPressed: _toggleRepeat,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Mini Player Widget (for taskbar)
// ================= MINI PLAYER =================

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final _player = GlobalMusicPlayer.instance;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to custom state changes
    _stateSubscription = _player.onPlayingStateChanged.listen((_) {
      if (mounted) setState(() {});
    });

    // Also listen to actual player state changes
    _playerStateSubscription = _player.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _player.isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void _openPlayer() {
    if (_player.currentSong != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => MusicPlayerPage(
            song: _player.currentSong!,
            playlist: _player.playlist,
            currentIndex: _player.currentIndex,
          ),
        ),
      );
    }
  }

  void _playPause() async {
    if (_player.isPlaying) {
      await _player.audioPlayer.pause();
    } else {
      await _player.audioPlayer.resume();
    }
    // State will be updated automatically by the listener
  }

  void _playNext() async {
    if (_player.currentIndex < _player.playlist.length - 1) {
      setState(() {
        _player.currentIndex++;
        _player.currentSong = _player.playlist[_player.currentIndex];
      });

      await _player.audioPlayer.stop();
      await _player.audioPlayer
          .play(UrlSource(_player.currentSong!.audioUrl));
    }
  }

  void _playPrevious() async {
    if (_player.currentIndex > 0) {
      setState(() {
        _player.currentIndex--;
        _player.currentSong = _player.playlist[_player.currentIndex];
      });

      await _player.audioPlayer.stop();
      await _player.audioPlayer
          .play(UrlSource(_player.currentSong!.audioUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_player.currentSong == null) return const SizedBox.shrink();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // 🎵 Album Art
          GestureDetector(
            onTap: _openPlayer,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _player.currentSong!.imageUrl,
                height: 48,
                width: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 48,
                  width: 48,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.music_note,
                      color: Colors.white54),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🎶 Song Info
          Expanded(
            child: GestureDetector(
              onTap: _openPlayer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _player.currentSong!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _player.currentSong!.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // ⏮️ Previous
          IconButton(
            icon: const Icon(Icons.skip_previous,
                color: Colors.white, size: 28),
            onPressed:
            _player.currentIndex > 0 ? _playPrevious : null,
          ),

          // ▶️ / ⏸️ Play Pause
          IconButton(
            icon: Icon(
              _player.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
            onPressed: _playPause,
          ),

          // ⏭️ Next
          IconButton(
            icon: const Icon(Icons.skip_next,
                color: Colors.white, size: 28),
            onPressed: _player.currentIndex <
                _player.playlist.length - 1
                ? _playNext
                : null,
          ),
        ],
      ),
    );
  }
}