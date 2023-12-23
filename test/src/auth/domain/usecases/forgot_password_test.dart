import 'package:dartz/dartz.dart';
import 'package:gs_orange/src/auth/domain/usecases/forgot_password.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth_repo.mock.dart';

void main() {
  late MockAuthRepo repo;
  late ForgotPassword usecase;

  setUp(() {
    repo = MockAuthRepo();
    usecase = ForgotPassword(repo);
  });

  test(
    'should call the [AuthRepo.forgotPassword]',
    () async {
      when(() => repo.forgotPassword(any())).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await usecase('email');

      expect(result, equals(const Right<dynamic, void>(null)));

      verify(() => repo.forgotPassword('email')).called(1);

      verifyNoMoreInteractions(repo);
    },
  );
}
