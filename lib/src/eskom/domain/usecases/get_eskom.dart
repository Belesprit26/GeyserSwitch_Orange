import 'package:gs_orange/core/usecases/usecases.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';
import 'package:gs_orange/src/eskom/domain/repos/eskom_repo.dart';

class GetEskom extends UsecaseWithoutParams<List<Eskom>> {
  const GetEskom(this._repository);

  final EskomAuthRepo _repository;

  @override
  ResultFuture<List<Eskom>> call() async => _repository.getEskom();
}
