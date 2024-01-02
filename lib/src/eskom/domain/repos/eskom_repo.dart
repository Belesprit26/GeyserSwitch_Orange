import 'package:dartz/dartz.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/auth/domain/entities/eskom.dart';

abstract class EskomAuthRepo {
  const EskomAuthRepo();

  ResultFuture<List<Eskom>> getEskom();
}
