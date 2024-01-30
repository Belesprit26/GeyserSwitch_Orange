import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/loadshedding/data/models/loadshedding_model.dart';
import 'package:gs_orange/src/loadshedding/data/repository/loadshedding_repository_implementation.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';
import 'package:gs_orange/src/loadshedding/domain/repository/loadshedding_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockLoadSheddingRemoteDataSource mockLoadSheddingRemoteDataSource;
  late LoadSheddingRepositoryImpl loadSheddingRepositoryImpl;

  setUp(() {
    mockLoadSheddingRemoteDataSource = MockLoadSheddingRemoteDataSource();
    loadSheddingRepositoryImpl = LoadSheddingRepositoryImpl(
        loadSheddingRemoteDataSource: mockLoadSheddingRemoteDataSource);
  });

  const testLoadsheddingModel = LoadSheddingModel(
    cityName: 'National',
    stage: '1',
    stageUpdated: 'stageUpdated',
  );

  const testLoadsheddingEntity = LoadSheddingEntity(
    cityName: 'National',
    stage: '1',
    stageUpdated: 'stageUpdated',
  );

  const testCityName = 'National';

  group('get current stage', () {
    test('should return current stage successfully when call is made',
        () async {
      //arrange
      when(mockLoadSheddingRemoteDataSource.getCurrentStage(testCityName))
          .thenAnswer((_) async => testLoadsheddingModel);
      //act
      final result =
          await loadSheddingRepositoryImpl.getCurrentStage(testCityName);
      //assert
      expect(result, equals(const Right(testLoadsheddingEntity)));
    });

    test(
      'should return server failure when a call to data source is unsuccessful',
      () async {
        // arrange
        when(mockLoadSheddingRemoteDataSource.getCurrentStage(testCityName))
            .thenThrow(ServersException());

        // act
        final result =
            await loadSheddingRepositoryImpl.getCurrentStage(testCityName);

        // assert
        expect(result,
            equals(const Left(ServersFailure('An error has occurred'))));
      },
    );

    test(
      'should return connection failure when the device has no internet',
      () async {
        // arrange
        when(mockLoadSheddingRemoteDataSource.getCurrentStage(testCityName))
            .thenThrow(
                const SocketException('Failed to connect to the network'));

        // act
        final result =
            await loadSheddingRepositoryImpl.getCurrentStage(testCityName);

        // assert
        expect(
            result,
            equals(const Left(
                ConnectionsFailure('Failed to connect to the network'))));
      },
    );
  });
}
