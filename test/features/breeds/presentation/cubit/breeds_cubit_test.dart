import 'package:bloc_test/bloc_test.dart';
import 'package:cat_nextep_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_nextep_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_nextep_app/features/breeds/presentation/cubit/breeds_cubit.dart';
import 'package:cat_nextep_app/features/breeds/presentation/cubit/breeds_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreedsRepository extends Mock implements BreedsRepository {}

void main() {
  late BreedsRepository repository;

  const breedA = Breed(
    breed: 'Gato comun',
    country: 'Argentina',
    origin: 'Domestico',
    coat: 'Corto',
    pattern: 'Atigrado',
  );

  const breedB = Breed(
    breed: 'Siames',
    country: 'Argentina',
    origin: 'Criadero',
    coat: 'Corto',
    pattern: 'Bicolor',
  );

  const breedC = Breed(
    breed: 'Persa',
    country: 'Argentina',
    origin: 'Domestico',
    coat: 'Largo',
    pattern: 'Solido',
  );

  setUp(() {
    repository = _MockBreedsRepository();
  });

  group('BreedsCubit', () {
    blocTest<BreedsCubit, BreedsState>(
      'carga inicial exitosa emite loading y luego success con datos',
      build: () {
        when(
          () => repository.getBreeds(page: 1, limit: 2),
        ).thenAnswer((_) async => [breedA, breedB]);

        return BreedsCubit(
          breedsRepository: repository,
          pageSize: 2,
        );
      },
      act: (cubit) => cubit.fetchInitialBreeds(),
      expect: () => [
        const BreedsState(status: BreedsStatus.loading),
        const BreedsState(
          status: BreedsStatus.success,
          breeds: [breedA, breedB],
          page: 1,
          hasReachedEnd: false,
        ),
      ],
      verify: (_) {
        verify(() => repository.getBreeds(page: 1, limit: 2)).called(1);
      },
    );

    blocTest<BreedsCubit, BreedsState>(
      'paginacion agrega datos a la lista existente',
      build: () {
        when(
          () => repository.getBreeds(page: 2, limit: 2),
        ).thenAnswer((_) async => [breedC]);

        return BreedsCubit(
          breedsRepository: repository,
          pageSize: 2,
        );
      },
      seed: () => const BreedsState(
        status: BreedsStatus.success,
        breeds: [breedA, breedB],
        page: 1,
        hasReachedEnd: false,
      ),
      act: (cubit) => cubit.fetchNextPage(),
      expect: () => [
        const BreedsState(
          status: BreedsStatus.success,
          breeds: [breedA, breedB],
          page: 1,
          hasReachedEnd: false,
          isFetchingMore: true,
        ),
        const BreedsState(
          status: BreedsStatus.success,
          breeds: [breedA, breedB, breedC],
          page: 2,
          hasReachedEnd: true,
          isFetchingMore: false,
        ),
      ],
      verify: (_) {
        verify(() => repository.getBreeds(page: 2, limit: 2)).called(1);
      },
    );

    blocTest<BreedsCubit, BreedsState>(
      'error en carga inicial emite failure con mensaje amigable',
      build: () {
        when(
          () => repository.getBreeds(page: 1, limit: 2),
        ).thenThrow(Exception('network down'));

        return BreedsCubit(
          breedsRepository: repository,
          pageSize: 2,
        );
      },
      act: (cubit) => cubit.fetchInitialBreeds(),
      expect: () => [
        const BreedsState(status: BreedsStatus.loading),
        const BreedsState(
          status: BreedsStatus.failure,
          errorMessage: 'No se pudieron cargar las razas.',
        ),
      ],
    );

    blocTest<BreedsCubit, BreedsState>(
      'error en paginacion no borra datos previos',
      build: () {
        when(
          () => repository.getBreeds(page: 2, limit: 2),
        ).thenThrow(Exception('timeout'));

        return BreedsCubit(
          breedsRepository: repository,
          pageSize: 2,
        );
      },
      seed: () => const BreedsState(
        status: BreedsStatus.success,
        breeds: [breedA, breedB],
        page: 1,
        hasReachedEnd: false,
      ),
      act: (cubit) => cubit.fetchNextPage(),
      expect: () => [
        const BreedsState(
          status: BreedsStatus.success,
          breeds: [breedA, breedB],
          page: 1,
          hasReachedEnd: false,
          isFetchingMore: true,
        ),
        const BreedsState(
          status: BreedsStatus.success,
          breeds: [breedA, breedB],
          page: 1,
          hasReachedEnd: false,
          isFetchingMore: false,
          paginationErrorMessage: 'No se pudieron cargar mas razas.',
        ),
      ],
    );
  });
}