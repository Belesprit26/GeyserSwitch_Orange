import 'package:gs_orange/core/utils/typdefs.dart';

abstract class OnBoardingRepo {
  const OnBoardingRepo();

  ResultFuture<void> cacheFirstTimer();

  ResultFuture<bool> checkIfUserIsFirstTimer();
}
