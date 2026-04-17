import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'features/breeds/data/repositories/breeds_repository_impl.dart';
import 'features/breeds/domain/repositories/breeds_repository.dart';
import 'features/breeds/presentation/cubit/breeds_cubit.dart';
import 'features/breeds/presentation/pages/breeds_page.dart';
import 'features/facts/data/datasources/cat_facts_remote_datasource.dart';
import 'features/facts/data/repositories/cat_facts_repository_impl.dart';
import 'features/facts/domain/repositories/cat_facts_repository.dart';

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
  late final BreedsRepository _breedsRepository;
  late final CatFactsRepository _catFactsRepository;

  @override
  void initState() {
    super.initState();

    _breedsRepository = BreedsRepositoryImpl(
      remoteDataSource: BreedsRemoteDataSourceImpl(client: _httpClient),
    );
    _catFactsRepository = CatFactsRepositoryImpl(
      remoteDataSource: CatFactsRemoteDataSourceImpl(client: _httpClient),
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BreedsRepository>.value(value: _breedsRepository),
        RepositoryProvider<CatFactsRepository>.value(value: _catFactsRepository),
      ],
      child: BlocProvider<BreedsCubit>(
        create: (context) =>
            BreedsCubit(breedsRepository: context.read<BreedsRepository>())
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
      ),
    );
  }
}
