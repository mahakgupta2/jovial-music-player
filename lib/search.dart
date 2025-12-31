import 'package:flutter/material.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';
import 'package:mymusicplayer_new/favorites_store.dart';
import 'music_player_page.dart'; // Import music player

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController _controller = TextEditingController();
  final _player = GlobalMusicPlayer.instance;
  List<Song> allSongs = [];
  List<Song> filteredSongs = [];

  @override
  void initState() {
    super.initState();

    // 🔥 All Songs
    allSongs = [
      Song(
        title: 'Tum Ho Toh',
        subtitle: 'Saiyaara',
        year: '2025',
        imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1coq55KYPnS0iCMJihGPx1IfpdOku4ELzJA&s',
        audioUrl:
        'https://res.cloudinary.com/dawjttakh/video/upload/v1752387522/Tum_Ho_Toh_Saiyaara_320_Kbps_it7faa.mp3',
      ),
      Song(
        title: 'Ishq Mein',
        subtitle: 'Nadaaniyan',
        year: '2025',
        imageUrl:
        'https://a10.gaanacdn.com/gn_img/albums/Bp1bAnK029/1bANwkGXK0/size_m.jpg',
        audioUrl:
        'https://res.cloudinary.com/dawjttakh/video/upload/v1753305736/Ishq_Mein_Nadaaniyan_320_Kbps_ko2g1b.mp3',
      ),
      Song(
        title: 'Haqeeqat',
        subtitle: 'Akhil Sachdeva',
        year: '2025',
        imageUrl:
        'https://i.ytimg.com/vi/gmaxofTxvm0/hq720.jpg',
        audioUrl:
        'https://res.cloudinary.com/dawjttakh/video/upload/v1752387585/Haqeeqat_Akhil_Sachdeva_320_Kbps_b8m8hs.mp3',
      ),
      Song(
        title: 'Pehla Tu Duja Tu',
        subtitle: 'Son of Sardaar',
        year: '2025',
        imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREZbEZPmJYbKTX2IBVMqZLCxL8AzQrjd9T6w&s',
        audioUrl:
        'https://res.cloudinary.com/dawjttakh/video/upload/v1752387677/Pehla_Tu_Duja_Tu_Son_Of_Sardaar_2_320_Kbps_czvarv.mp3',
      ),
    ];

    filteredSongs = allSongs;

    // 🔁 Auto refresh favorites and player state
    FavoritesStore.instance.listenable.addListener(_refresh);
    _player.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() {});
    });
  }

  void _refresh() => setState(() {});

  void _filterSongs(String query) {
    setState(() {
      filteredSongs = allSongs.where((song) {
        final q = query.toLowerCase();
        return song.title.toLowerCase().contains(q) ||
            song.subtitle.toLowerCase().contains(q);
      }).toList();
    });
  }

  // Open Music Player
  void _openMusicPlayer(Song song, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(
          song: song,
          playlist: filteredSongs, // Use filtered songs as playlist
          currentIndex: index,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    FavoritesStore.instance.listenable.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveSong = _player.currentSong != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                hasActiveSong ? 85 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search Bar
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onChanged: _filterSongs,
                    decoration: InputDecoration(
                      hintText: "Search songs",
                      hintStyle: const TextStyle(color: Colors.yellow),
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Jovial Songs",
                    style: TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // 🎵 Song List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = filteredSongs[index];
                        return MusicTile(
                          song: song,
                          onTap: () => _openMusicPlayer(song, index),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
}

// 🔹 SONG TILE WITH TAP
class MusicTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const MusicTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = FavoritesStore.instance.contains(song);

    return ListTile(
      onTap: onTap, // Open player on tap
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          song.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        song.subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.white60,
        ),
        onPressed: () {
          FavoritesStore.instance.toggle(song);
        },
      ),
    );
  }
}