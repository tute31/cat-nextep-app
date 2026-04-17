import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/breed.dart';
import '../../domain/repositories/breeds_repository.dart';
import 'breeds_state.dart';

class BreedsCubit extends Cubit<BreedsState> {
  BreedsCubit({
    required BreedsRepository breedsRepository,
    int pageSize = 10,
  })  : _breedsRepository = breedsRepository,
        _pageSize = pageSize,
        super(const BreedsState());

  final BreedsRepository _breedsRepository;
  final int _pageSize;

  Future<void> fetchInitialBreeds() async {
    if (state.status == BreedsStatus.loading) {
      return;
    }

    emit(
      const BreedsState(
        status: BreedsStatus.loading,
      ),
    );

    try {
      final List<Breed> breeds = await _breedsRepository.getBreeds(
        page: 1,
        limit: _pageSize,
      );

      emit(
        BreedsState(
          status: BreedsStatus.success,
          breeds: breeds,
          page: 1,
          hasReachedEnd: breeds.length < _pageSize,
        ),
      );
    } catch (error) {
      emit(
        BreedsState(
          status: BreedsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.status != BreedsStatus.success ||
        state.isFetchingMore ||
        state.hasReachedEnd) {
      return;
    }

    final int nextPage = state.page + 1;

    emit(
      state.copyWith(
        isFetchingMore: true,
        clearPaginationErrorMessage: true,
      ),
    );

    try {
      final List<Breed> nextBreeds = await _breedsRepository.getBreeds(
        page: nextPage,
        limit: _pageSize,
      );

      emit(
        state.copyWith(
          breeds: <Breed>[...state.breeds, ...nextBreeds],
          page: nextPage,
          hasReachedEnd: nextBreeds.length < _pageSize,
          isFetchingMore: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isFetchingMore: false,
          paginationErrorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> retry() async {
    if (state.status == BreedsStatus.failure) {
      await fetchInitialBreeds();
      return;
    }

    if (state.paginationErrorMessage != null) {
      await fetchNextPage();
    }
  }
}