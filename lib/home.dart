import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';
import 'package:mymusicplayer_new/music.dart';
import 'package:mymusicplayer_new/favorites_store.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    FavoritesStore.instance.listenable.addListener(_onFavChanged);
  }

  void _onFavChanged() => setState(() {});

  @override
  void dispose() {
    FavoritesStore.instance.listenable.removeListener(_onFavChanged);
    super.dispose();
  }

  static final List<Song> featuredSongs = [
    Song(
      title: "Dead inside",
      subtitle: "LoFi Track",
      year: "2019",
      imageUrl: "https://i.scdn.co/image/ab67616d0000b2736539071e0f1833190a491d4d",
      audioUrl: "https://res.cloudinary.com/dawjttakh/video/upload/v1752387522/Tum_Ho_Toh_Saiyaara_320_Kbps_it7faa.mp3",
    ),
    Song(
      title: "Alone",
      subtitle: "LoFi Track",
      year: "2016",
      imageUrl: "https://www.koimoi.com/wp-content/new-galleries/2016/02/sanam-teri-kasam-review-2.jpg",
      audioUrl: "https://res.cloudinary.com/dawjttakh/video/upload/v1752345880/Tu_Hai_To_Mujhe_Fir_Aur_Kya_Chahiye__Slowed___Reverb__Lofi_Ringtone___Love_Ringtone___New_Ringtone__256k_sc6s4y.mp3",
    ),
    Song(
      title: "Heartless",
      subtitle: "LoFi Track",
      year: "2015",
      imageUrl: "https://img.youtube.com/vi/fs7-8M1VbZU/sddefault.jpg",
      audioUrl: "https://res.cloudinary.com/dawjttakh/video/upload/v1752387522/Tum_Ho_Toh_Saiyaara_320_Kbps_it7faa.mp3",
    ),
  ];

  static final List<Song> popularSingers = [
    Song(
      title: "Arijit Singh",
      subtitle: "2023 • O Mahi",
      year: "2023",
      imageUrl: "https://d3lzcn6mbbadaf.cloudfront.net/media/details/ANI-20230824155330.jpg",
      audioUrl: "https://res.cloudinary.com/dawjttakh/video/upload/v1752387585/Haqeeqat_Akhil_Sachdeva_320_Kbps_b8m8hs.mp3",
    ),
    Song(
      title: "Shreya Ghoshal",
      subtitle: "2024 • Angaaron",
      year: "2024",
      imageUrl: "https://d3lzcn6mbbadaf.cloudfront.net/media/details/ANI-20230824155330.jpg",
      audioUrl: "https://res.cloudinary.com/dawjttakh/video/upload/v1752387677/Pehla_Tu_Duja_Tu_Son_Of_Sardaar_2_320_Kbps_czvarv.mp3",
    ),
  ];

  // 🔥 Firestore Songs Stream
  Stream<List<Song>> getLatestSongsFromFirestore() {
    return FirebaseFirestore.instance
        .collection('songs')
        .orderBy('year', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return Song(
        title: data['title'] ?? '',
        subtitle: data['subtitle'] ?? '',
        year: data['year'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        audioUrl: data['audioUrl'] ?? '',
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Hero Section
              Stack(
                children: [
                  Image.network(
                    featuredSongs[1].imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                featuredSongs[1].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MusicPage(song: featuredSongs[1]),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                child: const Text(
                                  "Play Now",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildSectionTitle("Discography"),
              _buildHorizontalSongRow(context, featuredSongs),

              _buildSectionTitle("Popular Singers"),
              ...popularSingers.map((song) => _buildSongTile(context, song)),

              // 🔥 Latest Songs from Firebase
              const SizedBox(height: 20),
              _buildSectionTitle("Latest Songs"),
              StreamBuilder<List<Song>>(
                stream: getLatestSongsFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Failed to load songs", style: TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("No latest songs yet", style: TextStyle(color: Colors.white70)),
                    );
                  }

                  final latestSongs = snapshot.data!;
                  return _buildHorizontalSongRow(context, latestSongs);
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text("See all", style: TextStyle(color: Colors.white70)),
      ],
    ),
  );

  Widget _buildHorizontalSongRow(BuildContext context, List<Song> songs) => SizedBox(
    height: 160,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isFav = FavoritesStore.instance.contains(song);

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MusicPage(song: song)),
              ),
              child: Container(
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
                    Text(song.title, style: const TextStyle(color: Colors.white)),
                    Text(song.year, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
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
        );
      },
    ),
  );

  Widget _buildSongTile(BuildContext context, Song song) {
    final isFav = FavoritesStore.instance.contains(song);

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(song.imageUrl, height: 50, width: 50, fit: BoxFit.cover),
      ),
      title: Text(song.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(song.subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white60,
            ),
            onPressed: () => FavoritesStore.instance.toggle(song),
          ),
          const Icon(Icons.play_arrow, color: Colors.white),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MusicPage(song: song)),
      ),
    );
  }
}