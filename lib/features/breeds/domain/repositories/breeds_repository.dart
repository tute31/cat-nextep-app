import '../entities/breed.dart';

abstract class BreedsRepository {
  Future<List<Breed>> getBreeds({
    required int page,
    required int limit,
  });
}