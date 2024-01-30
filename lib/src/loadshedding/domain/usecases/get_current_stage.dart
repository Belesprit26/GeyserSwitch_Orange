import 'package:dartz/dartz.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';
import 'package:gs_orange/src/loadshedding/domain/repository/loadshedding_repository.dart';

class GetCurrentStageUsecase {
  final LoadSheddingRepository loadSheddingRepository;

  GetCurrentStageUsecase(this.loadSheddingRepository);

  Future<Either<Failures, LoadSheddingEntity>> execute(String cityName) {
    return loadSheddingRepository.getCurrentStage(cityName);
  }
}
