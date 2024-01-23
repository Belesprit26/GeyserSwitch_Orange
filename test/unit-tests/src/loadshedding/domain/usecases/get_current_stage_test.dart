import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';
import 'package:gs_orange/src/loadshedding/domain/usecases/get_current_stage.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late GetCurrentStageUsecase getCurrentStageUsecase;
  late MockLoadSheddingRepository mockLoadSheddingRepository;

  setUp(() {
    mockLoadSheddingRepository = MockLoadSheddingRepository();
    getCurrentStageUsecase = GetCurrentStageUsecase(mockLoadSheddingRepository);
  });

  const testLoadsheddingDetail = LoadSheddingEntity(
    cityName: 'National',
    stage: '1',
    stageUpdated: 'stageUpdated',
  );

  const testCityName = 'National';

  test('should [get current weather] details from the repo', () async {
    //arrange
    when(mockLoadSheddingRepository.getCurrentStage(testCityName))
        .thenAnswer((_) async => const Right(testLoadsheddingDetail));

    //act
    final result = await getCurrentStageUsecase.execute(testCityName);
    //assert
    expect(result, const Right(testLoadsheddingDetail));
  });
}

//  test('', () async {
//     //arrange
//
//     //act
//
//     //assert
//   });
