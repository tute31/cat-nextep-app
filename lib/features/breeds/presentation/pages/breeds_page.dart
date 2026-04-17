import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/breeds_cubit.dart';
import '../cubit/breeds_state.dart';
import '../widgets/breed_list_item.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({super.key});

  @override
  State<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends State<BreedsPage> {
  static const _scrollThreshold = 200.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _scrollThreshold) {
      context.read<BreedsCubit>().fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Breeds'),
      ),
      body: BlocBuilder<BreedsCubit, BreedsState>(
        builder: (context, state) {
          final String query = state.searchQuery.toLowerCase();
          final bool isSearching = query.isNotEmpty;
          final filteredBreeds = state.breeds.where((breed) {
            final name = breed.breed.toLowerCase();
            final country = breed.country.toLowerCase();
            final origin = breed.origin.toLowerCase();
            return name.contains(query) ||
                country.contains(query) ||
                origin.contains(query);
          }).toList();

          if (state.status == BreedsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BreedsStatus.failure) {
            return _ErrorStateView(
              message: state.errorMessage ?? 'Could not load breeds.',
              onRetry: () => context.read<BreedsCubit>().retry(),
            );
          }

          if (state.breeds.isEmpty) {
            return const Center(child: Text('No breeds found.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  onChanged: context.read<BreedsCubit>().updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by breed, country or origin',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: filteredBreeds.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No matches for your search.'),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBreeds.length + (isSearching ? 0 : 1),
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (!isSearching && index == filteredBreeds.length) {
                            return _PaginationFooter(
                              isFetchingMore: state.isFetchingMore,
                              paginationErrorMessage:
                                  state.paginationErrorMessage,
                              onRetry: () => context.read<BreedsCubit>().retry(),
                            );
                          }

                          return BreedListItem(breed: filteredBreeds[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorStateView extends StatelessWidget {
  const _ErrorStateView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isFetchingMore,
    required this.paginationErrorMessage,
    required this.onRetry,
  });

  final bool isFetchingMore;
  final String? paginationErrorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isFetchingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (paginationErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              'Could not load more breeds.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}