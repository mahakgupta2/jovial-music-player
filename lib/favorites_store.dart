import 'package:flutter/foundation.dart';
import 'package:mymusicplayer_new/data/models/auth/song_model.dart';

/// A simple in-memory store for favorite songs.
class FavoritesStore {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  final Map<String, Song> _map = {};
  final ValueNotifier<int> listenable = ValueNotifier<int>(0);

  List<Song> get items => _map.values.toList(growable: false);

  bool contains(Song song) => _map.containsKey(song.audioUrl);

  void toggle(Song song) {
    if (contains(song)) {
      _map.remove(song.audioUrl);
    } else {
      _map[song.audioUrl] = song;
    }
    listenable.value++; // Notify listeners to rebuild
  }
}
