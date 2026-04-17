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

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.breeds.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == state.breeds.length) {
                return _PaginationFooter(
                  isFetchingMore: state.isFetchingMore,
                  paginationErrorMessage: state.paginationErrorMessage,
                  onRetry: () => context.read<BreedsCubit>().retry(),
                );
              }

              return BreedListItem(breed: state.breeds[index]);
            },
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