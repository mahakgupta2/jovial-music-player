class Song {
  final String title;
  final String subtitle; // ← ✅ Add this
  final String year;
  final String imageUrl;
  final String audioUrl;

  const Song({
    required this.title,
    required this.subtitle, // ← ✅ Required now
    required this.year,
    required this.imageUrl,
    required this.audioUrl,
  });
  factory Song.fromFirestore (Map<String, dynamic> data) {
    return Song(
      title: data['title'],
      subtitle: data['subtitle'],
      year: data['year'],
      imageUrl: data['imageUrl'],
      audioUrl: data['audioUrl'],
    );
  }
}
