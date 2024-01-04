import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/src/eskom/data/datasources/eskmo_auth_remote_data_source.dart';
import 'package:gs_orange/src/eskom/data/repos/eskom_auth_repo_impl.dart';
import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';
import 'package:mocktail/mocktail.dart';

class MockEskomAuthRemoteDataSource extends Mock
    implements EskomAuthRemoteDataSource {}

void main() {
  late EskomAuthRemoteDataSource remoteDataSource;
  late EskomAuthRepoImpl repoImpl;

  setUp(() {
    remoteDataSource = MockEskomAuthRemoteDataSource();
    repoImpl = EskomAuthRepoImpl(remoteDataSource);
  });

  const tException =
      APIException(message: 'Unknown Error Occurred', statusCode: 500);

  group('getEskom', () {
    test(
      'Should call the [RemoteDataSource.getEskom]'
      ' and return List<Eskom> when call is successful',
      () async {
        //Arrange
        when(() => remoteDataSource.getEskom()).thenAnswer(
          (_) async => [],
        );
        //Act
        final result = await repoImpl.getEskom();

        //Assert
        expect(result, isA<Right<dynamic, List<Eskom>>>());
        verify(() => remoteDataSource.getEskom()).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return a [APIFailure] when the call to '
      'remote source is unsuccessful',
      () async {
        //Arrange
        when(() => remoteDataSource.getEskom()).thenThrow(tException);
        //Act
        final result = await repoImpl.getEskom();
        //Assert
        expect(result, equals(Left(ApiFailure.fromException(tException))));
        verify(() => remoteDataSource.getEskom()).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });
  //
}
