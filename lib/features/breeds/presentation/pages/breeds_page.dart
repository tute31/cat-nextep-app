import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/breeds_cubit.dart';
import '../cubit/breeds_state.dart';
import 'breed_detail_page.dart';
import '../widgets/breed_list_item.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({super.key});

  @override
  State<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends State<BreedsPage> {
  static const _scrollThreshold = 200.0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        title: const Text('Razas de Gatos'),
      ),
      body: BlocConsumer<BreedsCubit, BreedsState>(
        listenWhen: (previous, current) =>
            previous.paginationErrorMessage != current.paginationErrorMessage &&
            current.paginationErrorMessage != null,
        listener: (context, state) {
          final message = state.paginationErrorMessage;
          if (message == null) {
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message)),
            );
        },
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
              message: state.errorMessage ?? 'No se pudieron cargar las razas.',
              onRetry: () => context.read<BreedsCubit>().retry(),
            );
          }

          if (state.breeds.isEmpty) {
            return const Center(child: Text('No se encontraron razas.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: context.read<BreedsCubit>().updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar por raza, pais u origen',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: isSearching
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<BreedsCubit>().updateSearchQuery('');
                            },
                            icon: const Icon(Icons.close),
                            tooltip: 'Limpiar busqueda',
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filteredBreeds.length} resultados',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<BreedsCubit>().refreshBreeds(),
                  child: filteredBreeds.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 140),
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('No hay coincidencias para tu busqueda.'),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              filteredBreeds.length + (isSearching ? 0 : 1),
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (!isSearching && index == filteredBreeds.length) {
                              return _PaginationFooter(
                                isFetchingMore: state.isFetchingMore,
                                paginationErrorMessage:
                                    state.paginationErrorMessage,
                                onRetry: () =>
                                    context.read<BreedsCubit>().retry(),
                              );
                            }

                            final breed = filteredBreeds[index];
                            return BreedListItem(
                              breed: breed,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => BreedDetailPage(breed: breed),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
              child: const Text('Reintentar'),
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
              'No se pudieron cargar mas razas.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}