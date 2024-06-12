base class Artist {
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'] as String,
    );
  }
  Artist({
    required this.name,
  });

  @override
  int get hashCode => Object.hashAll([name]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Artist && name == other.name;

  final String name;
}
