class Breed {
  const Breed({
    required this.breed,
    required this.country,
    required this.origin,
    required this.coat,
    required this.pattern,
  });

  final String breed;
  final String country;
  final String origin;
  final String coat;
  final String pattern;

  Breed copyWith({
    String? breed,
    String? country,
    String? origin,
    String? coat,
    String? pattern,
  }) {
    return Breed(
      breed: breed ?? this.breed,
      country: country ?? this.country,
      origin: origin ?? this.origin,
      coat: coat ?? this.coat,
      pattern: pattern ?? this.pattern,
    );
  }
}