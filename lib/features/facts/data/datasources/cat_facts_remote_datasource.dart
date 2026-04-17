import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
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
    try {
      final uri = Uri.https(_host, '/fact');
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
      return CatFactModel.fromJson(decoded);
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