import '../entities/cat_fact.dart';

abstract class CatFactsRepository {
  Future<CatFact> getRandomFact();
}