import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/src/eskom/data/models/eskom_model.dart';
import 'package:gs_orange/src/loadshedding/data/models/loadshedding_model.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';

import '../../../../helpers/json_reader.dart';

void main() {
  const testLoadSheddingModel = LoadSheddingModel(
    cityName: "National",
    stage: "0",
    stageUpdated: "stage_updated",
  );

  test('should be a subclass of [loadshedding entity]', () async {
    //assert
    expect(testLoadSheddingModel, isA<LoadSheddingEntity>());
  });

  test('should return a valid model from Json', () async {
    //arrange
    final Map<String, dynamic> jsonMap = json.decode(
      readJson(
          'unit-tests/helpers/dummy_data/dummy_loadshedding_response.json'),
    );

    //act
    final result = LoadSheddingModel.fromJson(jsonMap);

    //assert
    expect(result, equals(testLoadSheddingModel));
  });

  test('should return a json map containing proper data', () async {
    //act
    final result = testLoadSheddingModel.toJson();

    //assert
    final expectedJsonMap = {
      'status': [
        {
          'eskom': [
            {
              'name': 'National',
              'stage': '0',
              'stageUpdated': 'stage_updated',
            },
          ],
        },
      ],
    };

    expect(result, equals(expectedJsonMap));
  });
}
