import 'package:dartz/dartz.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/eskom/data/datasources/eskom_auth_remote_data_source.dart';
import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';
import 'package:gs_orange/src/eskom/domain/repos/eskom_repo.dart';

class EskomAuthRepoImpl implements EskomAuthRepo {
  const EskomAuthRepoImpl(this._remoteDataSource);

  final EskomAuthRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<Eskom>> getEskom() async {
    try {
      final result = await _remoteDataSource.getEskom();
      return Right(result);
    } on APIException catch (e) {
      return Left(ApiFailure.fromException(e));
    }
  }
}
