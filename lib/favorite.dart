import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mymusicplayer_new/favorites_store.dart'; // ✅ import shared store
import 'package:mymusicplayer_new/data/models/auth/song_model.dart'; // ✅ for Song model

void main() => runApp(const Favoritepage());

class Favoritepage extends StatelessWidget {
  const Favoritepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    FavoritesStore.instance.listenable.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _audioPlayer.dispose();
    FavoritesStore.instance.listenable.removeListener(_refresh);
    super.dispose();
  }

  void _playSong(String url) async {
    if (_currentUrl != url) {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() => _currentUrl = url);
    } else {
      await _audioPlayer.pause();
      setState(() => _currentUrl = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = FavoritesStore.instance.items;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text('Favorite Songs', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: songs.isEmpty
          ? const Center(
        child: Text("No favorites yet!",
            style: TextStyle(color: Colors.white54,fontSize: 20,fontWeight: FontWeight.bold,)),
        ): ListView.builder(
        itemCount: songs.length,
        itemBuilder: (_, index) {
          final song = songs[index];
          return SongTile(
            song: song,
            isPlaying: _currentUrl == song.audioUrl,
            onPlayPause: () => _playSong(song.audioUrl),
            onRemove: () => FavoritesStore.instance.toggle(song),
          );
        },
      ),

    );
  }
}

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
      title: Text(song.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(song.subtitle, style: const TextStyle(color: Colors.white60)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.yellow,
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
