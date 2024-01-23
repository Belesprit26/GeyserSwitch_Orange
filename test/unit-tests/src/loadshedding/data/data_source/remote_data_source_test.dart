import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/utils/constants.dart';
import 'package:gs_orange/src/loadshedding/data/data_sources/remote_data_source.dart';
import 'package:gs_orange/src/loadshedding/data/models/loadshedding_model.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../../../helpers/json_reader.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late LoadSheddingRemoteDataSourceImpl loadSheddingRemoteDataSourceImpl;

  setUp(() {
    mockHttpClient = MockHttpClient();
    loadSheddingRemoteDataSourceImpl =
        LoadSheddingRemoteDataSourceImpl(client: mockHttpClient);
  });

  const testCityName = 'National';

  group('get current stage', () {
    test('should return loadshedding model when response code is 200',
        () async {
      //arrange
      when(mockHttpClient.get(Uri.parse(Urls.currentStageByName(testCityName))))
          .thenAnswer(
        (_) async => http.Response(
            readJson(
                'unit-tests/helpers/dummy_data/dummy_loadshedding_response.json'),
            200),
      );
      //act
      final result =
          await loadSheddingRemoteDataSourceImpl.getCurrentStage(testCityName);
      //assert
      expect(result, isA<LoadSheddingModel>());
    });

    test(
        'should return a server failure when request returns a 404 status code',
        () async {
      //arrange
      when(
        mockHttpClient.get(Uri.parse(Urls.currentStageByName(testCityName))),
      ).thenAnswer((_) async => http.Response('Not Found', 404));
      //act
      final result =
          loadSheddingRemoteDataSourceImpl.getCurrentStage(testCityName);
      //assert
      expect(result, throwsA(isA<ServersException>()));
    });
  });
}
