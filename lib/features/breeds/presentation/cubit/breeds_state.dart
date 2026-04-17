import 'package:equatable/equatable.dart';

import '../../domain/entities/breed.dart';

enum BreedsStatus { initial, loading, success, failure }

class BreedsState extends Equatable {
  const BreedsState({
    this.status = BreedsStatus.initial,
    this.breeds = const <Breed>[],
    this.page = 0,
    this.hasReachedEnd = false,
    this.isFetchingMore = false,
    this.errorMessage,
    this.paginationErrorMessage,
  });

  final BreedsStatus status;
  final List<Breed> breeds;
  final int page;
  final bool hasReachedEnd;
  final bool isFetchingMore;
  final String? errorMessage;
  final String? paginationErrorMessage;

  BreedsState copyWith({
    BreedsStatus? status,
    List<Breed>? breeds,
    int? page,
    bool? hasReachedEnd,
    bool? isFetchingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? paginationErrorMessage,
    bool clearPaginationErrorMessage = false,
  }) {
    return BreedsState(
      status: status ?? this.status,
      breeds: breeds ?? this.breeds,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      paginationErrorMessage: clearPaginationErrorMessage
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        breeds,
        page,
        hasReachedEnd,
        isFetchingMore,
        errorMessage,
        paginationErrorMessage,
      ];
}