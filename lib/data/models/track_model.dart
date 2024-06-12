import 'artists_model.dart';

base class Track {
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'] as String,
      href: json['href'] as String,
      id: json['id'] as String,
      artists: (json['artists'] as List)
          .map((artist) => Artist.fromJson(artist as Map<String, dynamic>))
          .toList(),
    );
  }
  Track({
    required this.name,
    required this.href,
    required this.id,
    required this.artists,
  });

  @override
  int get hashCode => Object.hashAll([name, href, id, artists]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          name == other.name &&
          href == other.href &&
          id == other.id &&
          artists == other.artists;

  final String name;
  final String href;
  final String id;
  final List<Artist> artists;
}
