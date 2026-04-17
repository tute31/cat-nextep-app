import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/breed.dart';
import '../../../facts/domain/entities/cat_fact.dart';
import '../../../facts/domain/repositories/cat_facts_repository.dart';

class BreedDetailPage extends StatefulWidget {
  const BreedDetailPage({
    super.key,
    required this.breed,
  });

  final Breed breed;

  @override
  State<BreedDetailPage> createState() => _BreedDetailPageState();
}

class _BreedDetailPageState extends State<BreedDetailPage> {
  late Future<CatFact> _factFuture;

  @override
  void initState() {
    super.initState();
    _factFuture = _fetchRandomFact();
  }

  Future<CatFact> _fetchRandomFact() {
    return context.read<CatFactsRepository>().getRandomFact();
  }

  void _retryFactRequest() {
    setState(() {
      _factFuture = _fetchRandomFact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breed.breed),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.breed.breed,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'General Information',
              children: [
                _InfoRow(label: 'Country', value: widget.breed.country),
                _InfoRow(label: 'Origin', value: widget.breed.origin),
                _InfoRow(label: 'Coat', value: widget.breed.coat),
                _InfoRow(label: 'Pattern', value: widget.breed.pattern),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Curious Fact',
              children: [
                FutureBuilder<CatFact>(
                  future: _factFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      final message = mapErrorToMessage(
                        snapshot.error!,
                        fallbackMessage:
                            'No se pudo cargar el dato curioso de gatos.',
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _retryFactRequest,
                            child: const Text('Try again'),
                          ),
                        ],
                      );
                    }

                    final fact = snapshot.data;
                    if (fact == null || fact.fact.isEmpty) {
                      return const Text('No fact available right now.');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fact.fact),
                        const SizedBox(height: 8),
                        Text(
                          'Length: ${fact.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _retryFactRequest,
                          child: const Text('Load another fact'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}