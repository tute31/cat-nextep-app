import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/breed_model.dart';

abstract class BreedsRemoteDataSource {
  Future<List<BreedModel>> getBreeds({
    required int page,
    required int limit,
  });
}

class BreedsRemoteDataSourceImpl implements BreedsRemoteDataSource {
  BreedsRemoteDataSourceImpl({required http.Client client}) : _client = client;

  final http.Client _client;

  static const _host = 'catfact.ninja';

  @override
  Future<List<BreedModel>> getBreeds({
    required int page,
    required int limit,
  }) async {
    final uri = Uri.https(_host, '/breeds', {
      'page': '$page',
      'limit': '$limit',
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch breeds. Status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? const []);

    return items
        .map((item) => BreedModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}