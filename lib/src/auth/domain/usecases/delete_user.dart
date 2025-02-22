import 'package:equatable/equatable.dart';
import 'package:gs_orange/core/usecases/usecases.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/auth/domain/repos/auth_repo.dart';

class DeleteUser extends UsecaseWithParams<void, DeleteUserParams> {
  final AuthRepo _repo;
  const DeleteUser(this._repo);

  @override
  ResultFuture<void> call(DeleteUserParams params) {
    return _repo.deleteUser(password: params.password); // Named parameter usage
  }
}

class DeleteUserParams extends Equatable {
  final String password;
  const DeleteUserParams({required this.password});

  @override
  List<Object?> get props => [password];
}