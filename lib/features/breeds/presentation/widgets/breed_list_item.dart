import 'package:flutter/material.dart';

import '../../domain/entities/breed.dart';

class BreedListItem extends StatelessWidget {
  const BreedListItem({
    super.key,
    required this.breed,
    this.onTap,
  });

  final Breed breed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      breed.breed,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 6),
              Text('Country: ${breed.country}'),
              Text('Origin: ${breed.origin}'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Coat: ${breed.coat}')),
                  Chip(label: Text('Pattern: ${breed.pattern}')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}