import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/src/auth/domain/repos/eskom_repo.dart';
import 'package:gs_orange/src/auth/domain/usecases/get_eskom.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements EskomAuthRepo {}

void main() {
  late GetEskom usecase;
  late EskomAuthRepo repository;

  setUp(() {
    repository = MockAuthRepo();
    usecase = GetEskom(repository);
  });

  test(
    'should call the [EskomRepo.getEskom]',
    () async {
      //Arrange

      //Act

      //Assert
    },
  );
}
