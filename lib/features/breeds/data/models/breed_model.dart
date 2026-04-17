import '../../domain/entities/breed.dart';

class BreedModel extends Breed {
  const BreedModel({
    required super.breed,
    required super.country,
    required super.origin,
    required super.coat,
    required super.pattern,
  });

  factory BreedModel.fromJson(Map<String, dynamic> json) {
    return BreedModel(
      breed: json['breed'] as String? ?? '',
      country: json['country'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      coat: json['coat'] as String? ?? '',
      pattern: json['pattern'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breed': breed,
      'country': country,
      'origin': origin,
      'coat': coat,
      'pattern': pattern,
    };
  }
}