import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cat_fact_model.dart';

abstract class CatFactsRemoteDataSource {
  Future<CatFactModel> getRandomFact();
}

class CatFactsRemoteDataSourceImpl implements CatFactsRemoteDataSource {
  CatFactsRemoteDataSourceImpl({required http.Client client})
      : _client = client;

  final http.Client _client;

  static const _host = 'catfact.ninja';

  @override
  Future<CatFactModel> getRandomFact() async {
    final uri = Uri.https(_host, '/fact');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch random fact. Status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return CatFactModel.fromJson(decoded);
  }
}