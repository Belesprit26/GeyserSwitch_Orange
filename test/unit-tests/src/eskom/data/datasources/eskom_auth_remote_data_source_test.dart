import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/utils/constants.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/eskom/data/datasources/eskom_auth_remote_data_source.dart';
import 'package:gs_orange/src/eskom/data/models/eskom_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  late http.Client client;
  late EskomAuthRemoteDataSource remoteDataSource;

  setUp(() {
    client = MockClient();
    remoteDataSource = EskomAuthRemoteDataSrcImpl(client);
    registerFallbackValue(Uri());
  });

  group('getEskom', () {
    const tEskom = [EskomModel.empty()];
    test(
      'Should return [List<EskomModel>] when status code is 200',
      () async {
        //Arrange
        when(() => client.get(any())).thenAnswer(
          (_) async => http.Response(jsonEncode([tEskom.first.toMap()]), 200),
        );
        //Act
        final result = await remoteDataSource.getEskom();

        //Assert
        expect(result, equals(tEskom));

        verify(() => client.get(
              Uri.https(kBaseUrl, kGetEskomEndpoint),
            )).called(1);
        verifyNoMoreInteractions(client);
      },
    );
    test('should throw [APIException] when the status code is 500', () async {
      final tMessage = 'Server down';

      when(() => client.get(any())).thenAnswer(
        (_) async => http.Response(
          tMessage,
          500,
        ),
      );

      final methodCall = remoteDataSource.getEskom();

      expect(
        () => methodCall,
        throwsA(
          APIException(message: tMessage, statusCode: 500),
        ),
      );

      verify(() => client.get(
            Uri.https(kBaseUrl, kGetEskomEndpoint),
          )).called(1);
      verifyNoMoreInteractions(client);
    });
  });
}
