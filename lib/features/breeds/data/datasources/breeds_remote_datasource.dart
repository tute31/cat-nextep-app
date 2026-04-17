import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
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
    try {
      final uri = Uri.https(_host, '/breeds', {
        'page': '$page',
        'limit': '$limit',
      });

      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw AppException(
          type: AppExceptionType.server,
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (decoded['data'] as List<dynamic>? ?? const []);

      return items
          .map((item) => BreedModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const AppException(type: AppExceptionType.network);
    } on http.ClientException {
      throw const AppException(type: AppExceptionType.network);
    } on FormatException {
      throw const AppException(type: AppExceptionType.parsing);
    } on TypeError {
      throw const AppException(type: AppExceptionType.parsing);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(type: AppExceptionType.unknown);
    }
  }
}