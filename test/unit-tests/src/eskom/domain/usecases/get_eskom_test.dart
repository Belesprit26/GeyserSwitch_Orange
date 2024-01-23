import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';
import 'package:gs_orange/src/eskom/domain/repos/eskom_repo.dart';
import 'package:gs_orange/src/eskom/domain/usecases/get_eskom.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements EskomAuthRepo {}

void main() {
  late GetEskom usecase;
  late EskomAuthRepo repository;

  setUp(() {
    repository = MockAuthRepo();
    usecase = GetEskom(repository);
  });

  const tResponse = [Eskom.empty()];

  test(
    'should call the [EskomRepo.getEskom] and return a [List<Eskom>]',
    () async {
      //Arrange
      when(() => repository.getEskom()).thenAnswer(
        (_) async => const Right(tResponse),
      );

      //Act
      final result = await usecase();

      //Assert
      expect(result, equals(const Right<dynamic, List<Eskom>>(tResponse)));
      verify(() => repository.getEskom()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
