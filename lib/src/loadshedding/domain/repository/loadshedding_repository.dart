import 'package:dartz/dartz.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';

abstract class LoadSheddingRepository {
  Future<Either<Failures, LoadSheddingEntity>> getCurrentStage(String cityName);
}
