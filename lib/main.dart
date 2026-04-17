import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'features/breeds/data/repositories/breeds_repository_impl.dart';
import 'features/breeds/presentation/cubit/breeds_cubit.dart';
import 'features/breeds/presentation/pages/breeds_page.dart';

void main() {
  runApp(const CatNextepApp());
}

class CatNextepApp extends StatefulWidget {
  const CatNextepApp({super.key});

  @override
  State<CatNextepApp> createState() => _CatNextepAppState();
}

class _CatNextepAppState extends State<CatNextepApp> {
  final http.Client _httpClient = http.Client();

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = BreedsRemoteDataSourceImpl(client: _httpClient);
    final repository = BreedsRepositoryImpl(remoteDataSource: remoteDataSource);

    return BlocProvider<BreedsCubit>(
      create: (_) => BreedsCubit(breedsRepository: repository)
        ..fetchInitialBreeds(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cat Nextep App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const BreedsPage(),
      ),
    );
  }
}
