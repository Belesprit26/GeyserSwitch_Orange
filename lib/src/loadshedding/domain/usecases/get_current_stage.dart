import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';
import 'package:gs_orange/src/loadshedding/domain/repository/loadshedding_repositiory.dart';

class GetCurrentStageUsecase {
  final LoadSheddingRepository loadSheddingRepository;

  GetCurrentStageUsecase(this.loadSheddingRepository);

  Future<Either<Failure, LoadSheddingEntity>> execute(String cityName) {
    return loadSheddingRepository.getCurrentStage(cityName);
  }
}
