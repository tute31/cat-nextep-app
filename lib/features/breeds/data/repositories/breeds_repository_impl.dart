import '../../domain/entities/breed.dart';
import '../../domain/repositories/breeds_repository.dart';
import '../datasources/breeds_remote_datasource.dart';

class BreedsRepositoryImpl implements BreedsRepository {
  BreedsRepositoryImpl({required BreedsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final BreedsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Breed>> getBreeds({
    required int page,
    required int limit,
  }) {
    return _remoteDataSource.getBreeds(page: page, limit: limit);
  }
}