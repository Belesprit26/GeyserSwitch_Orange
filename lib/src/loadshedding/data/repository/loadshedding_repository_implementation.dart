import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/loadshedding/data/data_sources/remote_data_source.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';
import 'package:gs_orange/src/loadshedding/domain/repository/loadshedding_repository.dart';

import '../../../../core/errors/exceptions.dart';

class LoadSheddingRepositoryImpl extends LoadSheddingRepository {
  final LoadSheddingRemoteDataSource loadSheddingRemoteDataSource;
  LoadSheddingRepositoryImpl({required this.loadSheddingRemoteDataSource});

  @override
  Future<Either<Failures, LoadSheddingEntity>> getCurrentStage(
      String cityName) async {
    try {
      final result =
          await loadSheddingRemoteDataSource.getCurrentStage(cityName);
      return Right(result.toEntity());
    } on ServersException {
      return const Left(ServersFailure('An error has occurred'));
    } on SocketException {
      return const Left(ConnectionsFailure('Failed to connect to the network'));
    }
  }
}
