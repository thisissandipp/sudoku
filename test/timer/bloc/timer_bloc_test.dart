// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sudoku/timer/timer.dart';

import '../../helpers/helpers.dart';

void main() {
  final ticker = MockTicker();
  final streamController = StreamController<int>.broadcast();

  setUp(() {
    when(ticker.tick).thenAnswer((_) => streamController.stream);
  });

  group('TimerBloc', () {
    test('initial state is TimerState', () {
      expect(
        TimerBloc(ticker: ticker).state,
        TimerState(),
      );
    });

    group('TimerStarted', () {
      test('emits 3 sequential timer states', () async {
        final bloc = TimerBloc(ticker: ticker)..add(TimerStarted(0));
        await bloc.stream.first;

        streamController
          ..add(1)
          ..add(2)
          ..add(3);

        await expectLater(
          bloc.stream,
          emitsInOrder(<TimerState>[
            TimerState(isRunning: true, secondsElapsed: 1),
            TimerState(isRunning: true, secondsElapsed: 2),
            TimerState(isRunning: true, secondsElapsed: 3),
          ]),
        );
      });
    });

    group('TimerTicked', () {
      blocTest<TimerBloc, TimerState>(
        'emits 1 when seconds elapsed is 1',
        build: () => TimerBloc(ticker: ticker),
        act: (bloc) => bloc.add(TimerTicked(1)),
        expect: () => [TimerState(secondsElapsed: 1)],
      );
    });

    group('TimerStopped', () {
      test('does not emit after timer is stopped', () async {
        final bloc = TimerBloc(ticker: ticker)..add(TimerStarted(0));

        expect(
          await bloc.stream.first,
          equals(
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 0,
            ),
          ),
        );

        streamController.add(1);
        expect(
          await bloc.stream.first,
          equals(
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 1,
            ),
          ),
        );

        bloc.add(TimerStopped());
        streamController.add(2);

        expect(
          await bloc.stream.first,
          equals(
            TimerState(
              isRunning: false,
              initialValue: 0,
              secondsElapsed: 1,
            ),
          ),
        );
      });
    });

    group('TimerResumed', () {
      test('resumes the timer from where it was stopped', () async {
        final bloc = TimerBloc(ticker: ticker)..add(TimerStarted(0));

        expect(
          await bloc.stream.first,
          equals(
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 0,
            ),
          ),
        );

        streamController
          ..add(1)
          ..add(2);

        await expectLater(
          bloc.stream,
          emitsInOrder(<TimerState>[
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 1,
            ),
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 2,
            ),
          ]),
        );

        bloc.add(TimerStopped());
        streamController.add(3);

        expect(
          await bloc.stream.first,
          equals(
            TimerState(
              isRunning: false,
              initialValue: 0,
              secondsElapsed: 2,
            ),
          ),
        );

        bloc.add(TimerResumed());
        streamController
          ..add(3)
          ..add(4)
          ..add(5);

        await expectLater(
          bloc.stream,
          emitsInOrder(<TimerState>[
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 2,
            ),
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 3,
            ),
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 4,
            ),
            TimerState(
              isRunning: true,
              initialValue: 0,
              secondsElapsed: 5,
            ),
          ]),
        );
      });
    });

    group('TimerReset', () {
      blocTest<TimerBloc, TimerState>(
        'emits new timer state',
        build: () => TimerBloc(ticker: ticker),
        act: (bloc) => bloc.add(TimerReset()),
        expect: () => [TimerState()],
      );
    });
  });
}
