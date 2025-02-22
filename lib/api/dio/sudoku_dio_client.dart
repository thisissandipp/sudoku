import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sudoku/api/api.dart';
import 'package:sudoku/api/dtos/dtos.dart';
import 'package:sudoku/env/env.dart';
import 'package:sudoku/models/models.dart';

/// {@template sudoku_dio_client}
/// An implemetation of the [SudokuAPI] using [Dio] as the http client.
/// {@endtemplate}
class SudokuDioClient extends SudokuAPI {
  /// {@macro sudoku_dio_client}
  SudokuDioClient({
    required String baseUrl,
    Dio? dioClient,
  }) : dioClient = dioClient != null
            ? (dioClient..options = BaseOptions(baseUrl: baseUrl))
            : Dio(BaseOptions(baseUrl: baseUrl));

  @visibleForTesting
  final Dio dioClient;

  Map<String, String> get _headers => {
        'x-api-key': Env.apiKey,
      };

  /// HTTP request path for creating sudoku
  static const createSudokuPath = '/createSudokuFlow';

  /// HTTP request path for generating hints
  static const generateHintPath = '/generateHintFlow';

  @override
  Future<Sudoku> createSudoku({required Difficulty difficulty}) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        createSudokuPath,
        data: CreateSudokuRequestDto(
          data: CreateSudokuRequest(difficulty: difficulty.name),
        ).toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: _headers,
        ),
      );

      if (response.data == null) {
        throw const SudokuAPIClientException();
      }

      final responseDto = CreateSudokuResponseDto.fromJson(response.data!);

      final puzzle = responseDto.result.puzzle;
      final solution = responseDto.result.solution;

      return Sudoku.fromRawData(puzzle, solution);
    } on SudokuInvalidRawDataException catch (_) {
      rethrow;
    } on DioException catch (error) {
      throw SudokuAPIClientException(error: error);
    } catch (e) {
      throw const SudokuAPIClientException();
    }
  }

  @override
  Future<Hint> generateHint({required Sudoku sudoku}) async {
    try {
      final (puzzle, solution) = sudoku.toRawData();
      final response = await dioClient.post<Map<String, dynamic>>(
        generateHintPath,
        data: GenerateHintRequestDto(
          data: GenerateHintRequest(puzzle: puzzle, solution: solution),
        ).toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: _headers,
        ),
      );

      if (response.data == null) {
        throw const SudokuAPIClientException();
      }

      final responseDto = GenerateHintResponseDto.fromJson(response.data!);
      return responseDto.result.toHint();
    } on DioException catch (error) {
      throw SudokuAPIClientException(error: error);
    } catch (e) {
      throw const SudokuAPIClientException();
    }
  }
}
