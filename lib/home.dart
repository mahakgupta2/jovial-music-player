import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';
import 'package:mymusicplayer_new/favorites_store.dart';
import 'music_player_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _player = GlobalMusicPlayer.instance;

  @override
  void initState() {
    super.initState();
    FavoritesStore.instance.listenable.addListener(_onFavChanged);

    // Listen to player state changes
    _player.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() {});
    });
  }

  void _onFavChanged() => setState(() {});

  @override
  void dispose() {
    FavoritesStore.instance.listenable.removeListener(_onFavChanged);
    super.dispose();
  }

  // Open Music Player
  void _openMusicPlayer(Song song, List<Song> playlist, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(
          song: song,
          playlist: playlist,
          currentIndex: index,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // 🔥 Static Songs
  static final List<Song> featuredSongs = [
    Song(
      title: "Dead Inside",
      subtitle: "LoFi Track",
      year: "2019",
      imageUrl:
      "https://i.scdn.co/image/ab67616d0000b2736539071e0f1833190a491d4d",
      audioUrl: "https://example.com/audio1.mp3",
    ),
    Song(
      title: "Alone",
      subtitle: "LoFi Track",
      year: "2016",
      imageUrl:
      "https://www.koimoi.com/wp-content/new-galleries/2016/02/sanam-teri-kasam-review-2.jpg",
      audioUrl: "https://example.com/audio2.mp3",
    ),
  ];

  static final List<Song> popularSingers = [
    Song(
      title: "Arijit Singh",
      subtitle: "2023 • O Mahi",
      year: "2023",
      imageUrl:
      "https://d3lzcn6mbbadaf.cloudfront.net/media/details/ANI-20230824155330.jpg",
      audioUrl: "https://example.com/audio3.mp3",
    ),
    Song(
      title: "Shreya Ghoshal",
      subtitle: "2024 • Angaaron",
      year: "2024",
      imageUrl:
      "https://d3lzcn6mbbadaf.cloudfront.net/media/details/ANI-20230824155330.jpg",
      audioUrl: "https://example.com/audio4.mp3",
    ),
  ];

  // 🔥 Firestore Songs
  Stream<List<Song>> getLatestSongsFromFirestore() {
    return FirebaseFirestore.instance
        .collection('songs')
        .orderBy('year', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Song(
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          year: data['year'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          audioUrl: data['audioUrl'] ?? '',
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveSong = _player.currentSong != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<List<Song>>(
              stream: getLatestSongsFromFirestore(),
              builder: (context, snapshot) {
                final latestSongs = snapshot.data ?? [];

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: hasActiveSong ? 125 : 60,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Hero Image
                      GestureDetector(
                        onTap: () => _openMusicPlayer(
                          featuredSongs[0],
                          featuredSongs,
                          0,
                        ),
                        child: Image.network(
                          featuredSongs[0].imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildSectionTitle("Discography"),
                      _buildHorizontalSongRow(featuredSongs),

                      _buildSectionTitle("Popular Singers"),
                      ...popularSingers.asMap().entries.map((entry) =>
                          _buildSongTile(entry.value, popularSingers, entry.key)),

                      const SizedBox(height: 20),

                      _buildSectionTitle("Latest Songs"),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (latestSongs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "No latest songs yet",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        _buildHorizontalSongRow(latestSongs),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),

            // Mini Player at bottom
            if (hasActiveSong)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MiniPlayer(),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 🔹 Horizontal Song List
  Widget _buildHorizontalSongRow(List<Song> songs) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final isFav = FavoritesStore.instance.contains(song);

          return GestureDetector(
            onTap: () => _openMusicPlayer(song, songs, index),
            child: Stack(
              children: [
                Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.imageUrl,
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.title,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.year,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white60,
                      size: 20,
                    ),
                    onPressed: () => FavoritesStore.instance.toggle(song),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 Vertical Song Tile
  Widget _buildSongTile(Song song, List<Song> playlist, int index) {
    final isFav = FavoritesStore.instance.contains(song);

    return ListTile(
      onTap: () => _openMusicPlayer(song, playlist, index),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          song.imageUrl,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        song.subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.white60,
        ),
        onPressed: () => FavoritesStore.instance.toggle(song),
      ),
    );
  }
}