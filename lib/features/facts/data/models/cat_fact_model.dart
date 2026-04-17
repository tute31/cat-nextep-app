import '../../domain/entities/cat_fact.dart';

class CatFactModel extends CatFact {
  const CatFactModel({
    required super.fact,
    required super.length,
  });

  factory CatFactModel.fromJson(Map<String, dynamic> json) {
    return CatFactModel(
      fact: json['fact'] as String? ?? '',
      length: json['length'] as int? ?? 0,
    );
  }
}