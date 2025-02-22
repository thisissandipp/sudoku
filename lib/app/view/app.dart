import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/api/api.dart';
import 'package:sudoku/home/home.dart';
import 'package:sudoku/l10n/l10n.dart';
import 'package:sudoku/repository/repository.dart';
import 'package:sudoku/theme/theme.dart';

class App extends StatelessWidget {
  const App({
    required SudokuAPI apiClient,
    required PuzzleRepository puzzleRepository,
    required AuthenticationRepository authenticationRepository,
    required PlayerRepository playerRepository,
    super.key,
  })  : _apiClient = apiClient,
        _puzzleRepository = puzzleRepository,
        _authenticationRepository = authenticationRepository,
        _playerRepository = playerRepository;

  final SudokuAPI _apiClient;
  final PuzzleRepository _puzzleRepository;
  final AuthenticationRepository _authenticationRepository;
  final PlayerRepository _playerRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SudokuAPI>.value(
          value: _apiClient,
        ),
        RepositoryProvider<PuzzleRepository>.value(
          value: _puzzleRepository,
        ),
        RepositoryProvider<AuthenticationRepository>.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider<PlayerRepository>.value(
          value: _playerRepository,
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: SudokuTheme.light,
      darkTheme: SudokuTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
        },
      ),
      home: const HomePage(),
    );
  }
}
