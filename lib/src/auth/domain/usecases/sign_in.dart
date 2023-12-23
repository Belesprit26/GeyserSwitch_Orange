import 'package:gs_orange/core/usecases/usecases.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/auth/domain/entities/user.dart';
import 'package:gs_orange/src/auth/domain/repos/auth_repo.dart';
import 'package:equatable/equatable.dart';

class SignIn extends UsecaseWithParams<LocalUser, SignInParams> {
  const SignIn(this._repo);

  final AuthRepo _repo;

  @override
  ResultFuture<LocalUser> call(SignInParams params) => _repo.signIn(
        email: params.email,
        password: params.password,
      );
}

class SignInParams extends Equatable {
  const SignInParams({
    required this.email,
    required this.password,
  });

  const SignInParams.empty()
      : email = '',
        password = '';

  final String email;
  final String password;

  @override
  List<String> get props => [email, password];
}
