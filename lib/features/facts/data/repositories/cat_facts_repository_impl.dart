import '../../domain/entities/cat_fact.dart';
import '../../domain/repositories/cat_facts_repository.dart';
import '../datasources/cat_facts_remote_datasource.dart';

class CatFactsRepositoryImpl implements CatFactsRepository {
  CatFactsRepositoryImpl({required CatFactsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CatFactsRemoteDataSource _remoteDataSource;

  @override
  Future<CatFact> getRandomFact() {
    return _remoteDataSource.getRandomFact();
  }
}