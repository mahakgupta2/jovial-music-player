import 'package:flutter/material.dart';
import 'package:mymusicplayer_new/music.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';
import 'package:mymusicplayer_new/favorites_store.dart'; // ✅ Import for favorite logic

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController _controller = TextEditingController();
  List<Song> allSongs = [];
  List<Song> filteredSongs = [];

  @override
  void initState() {
    super.initState();

    // ✅ Song list: All from Cloudinary
    allSongs = [
      Song(
        title: 'Tum Ho Toh',
        subtitle: 'Saiyaara',
        year: '2025',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1coq55KYPnS0iCMJihGPx1IfpdOku4ELzJA&s',
        audioUrl:
        'https://res.cloudinary.com/dawjttakh/video/upload/v1752387522/Tum_Ho_Toh_Saiyaara_320_Kbps_it7faa.mp3',
      ),
      Song(
        title: 'Ishq Mein',
        subtitle: 'Nadaaniyan',
        year: '2025',
        imageUrl: 'https://a10.gaanacdn.com/gn_img/albums/Bp1bAnK029/1bANwkGXK0/size_m.jpg',
        audioUrl: 'https://res.cloudinary.com/dawjttakh/video/upload/v1753305736/Ishq_Mein_Nadaaniyan_320_Kbps_ko2g1b.mp3',
      ),
      Song(
        title: 'Haqeeqat',
        subtitle: 'Akhil Sachdeva',
        year: '2025',
        imageUrl: 'https://i.ytimg.com/vi/gmaxofTxvm0/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLD4futLZheW3ZKMp9t8fDvdTavWLQ',
        audioUrl:
        'https://res.cloudinary.com/dawjttakh/video/upload/v1752387585/Haqeeqat_Akhil_Sachdeva_320_Kbps_b8m8hs.mp3',
      ),
      Song(
        title: 'Pehla Tu Duja Tu',
        subtitle: 'Son of Sardaar',
        year: '2025',
        imageUrl:'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREZbEZPmJYbKTX2IBVMqZLCxL8AzQrjd9T6w&s',
        audioUrl: 'https://res.cloudinary.com/dawjttakh/video/upload/v1752387677/Pehla_Tu_Duja_Tu_Son_Of_Sardaar_2_320_Kbps_czvarv.mp3',
      ),
    ];

    filteredSongs = allSongs
        .where((song) => song.audioUrl.contains('res.cloudinary.com'))
        .toList();

    // ✅ Auto-refresh when favorite updates
    FavoritesStore.instance.listenable.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  void _filterSongs(String query) {
    setState(() {
      filteredSongs = allSongs
          .where((song) =>
      song.audioUrl.contains('res.cloudinary.com') &&
          (song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.subtitle.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    FavoritesStore.instance.listenable.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Search Bar
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                onChanged: _filterSongs,
                decoration: InputDecoration(
                  hintText: "Search songs ",
                  hintStyle: const TextStyle(color: Colors.yellow),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Jovial Songs",
                  style: TextStyle(color: Colors.yellow, fontSize: 16)),
              const SizedBox(height: 12),

              // 🎵 Music List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = filteredSongs[index];
                    return MusicTile(song: song);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicTile extends StatelessWidget {
  final Song song;

  const MusicTile({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final isFav = FavoritesStore.instance.contains(song);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(song.imageUrl,
            width: 50, height: 50, fit: BoxFit.cover),
      ),
      title: Text(song.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(song.subtitle,
          style: const TextStyle(color: Colors.white60)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill,
                color: Colors.yellow, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MusicPage(song: song)),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white60,
            ),
            onPressed: () {
              FavoritesStore.instance.toggle(song);
            },
          ),
        ],
      ),
    );
  }
}