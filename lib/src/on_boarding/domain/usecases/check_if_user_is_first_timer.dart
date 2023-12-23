import 'package:gs_orange/core/usecases/usecases.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/on_boarding/domain/repos/on_boarding_repo.dart';

class CheckIfUserIsFirstTimer extends UsecaseWithoutParams<bool> {
  const CheckIfUserIsFirstTimer(this._repo);

  final OnBoardingRepo _repo;

  @override
  ResultFuture<bool> call() => _repo.checkIfUserIsFirstTimer();
}
