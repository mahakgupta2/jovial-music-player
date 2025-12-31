import 'package:flutter/material.dart';
import 'package:mymusicplayer_new/favorites_store.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';
import 'music_player_page.dart';

class Favoritepage extends StatelessWidget {
  const Favoritepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MusicPlayerScreen();
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _player = GlobalMusicPlayer.instance;

  @override
  void initState() {
    super.initState();
    FavoritesStore.instance.listenable.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FavoritesStore.instance.listenable.removeListener(_refresh);
    super.dispose();
  }

  void _openPlayer(List<Song> songs, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MusicPlayerPage(
          song: songs[index],
          playlist: songs,
          currentIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = FavoritesStore.instance.items;

    return Scaffold(
      backgroundColor: Colors.black,

      // ✅ APP BAR (NO BACK ARROW)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // ❌ removes arrow
        title: const Text(
          'Favorite Songs',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // 🔥 STACK for MiniPlayer
      body: Stack(
        children: [
          songs.isEmpty
              ? const Center(
            child: Text(
              "No favorites yet!",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: songs.length,
            itemBuilder: (_, index) {
              final song = songs[index];
              final isPlaying =
                  _player.currentSong?.audioUrl == song.audioUrl &&
                      _player.isPlaying;

              return SongTile(
                song: song,
                isPlaying: isPlaying,
                onPlayPause: () => _openPlayer(songs, index),
                onRemove: () =>
                    FavoritesStore.instance.toggle(song),
              );
            },
          ),

          // 🎵 MINI PLAYER (BOTTOM)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}

// ================= SONG TILE =================

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRemove;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(song.imageUrl),
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        song.subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.yellow,
              size: 28,
            ),
            onPressed: onPlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
