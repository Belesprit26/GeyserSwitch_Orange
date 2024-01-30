import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_bloc.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_event.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_state.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetCurrentStageUsecase mockGetCurrentStageUsecase;
  late LoadSheddingBloc loadSheddingBloc;

  setUp(() {
    mockGetCurrentStageUsecase = MockGetCurrentStageUsecase();
    loadSheddingBloc = LoadSheddingBloc(mockGetCurrentStageUsecase);
  });

  const testLoadshedding = LoadSheddingEntity(
    cityName: 'National',
    stage: '1',
    stageUpdated: 'stageUpdated',
  );

  const testCityName = 'National';

  test('initial state should be empty', () {
    expect(loadSheddingBloc.state, LoadSheddingEmpty());
  });

  blocTest<LoadSheddingBloc, LoadSheddingState>(
      'should emit [LoadSheddingLoading, LoadSheddingLoaded] when data is gotten successfully',
      build: () {
        when(mockGetCurrentStageUsecase.execute(testCityName))
            .thenAnswer((_) async => const Right(testLoadshedding));
        return loadSheddingBloc;
      },
      act: (bloc) => bloc.add(const OnCityChanged(testCityName)),
      wait: const Duration(milliseconds: 500),
      expect: () =>
          [LoadSheddingLoading(), const LoadSheddingLoaded(testLoadshedding)]);

  blocTest<LoadSheddingBloc, LoadSheddingState>(
      'should emit [LoadSheddingLoading, LoadSheddingLoadFailure] when get data is unsuccessful',
      build: () {
        when(mockGetCurrentStageUsecase.execute(testCityName)).thenAnswer(
            (_) async => const Left(ServersFailure('Server failure')));
        return loadSheddingBloc;
      },
      act: (bloc) => bloc.add(const OnCityChanged(testCityName)),
      wait: const Duration(milliseconds: 500),
      expect: () => [
            LoadSheddingLoading(),
            const LoadSheddingLoadFailure('Server failure'),
          ]);
}
