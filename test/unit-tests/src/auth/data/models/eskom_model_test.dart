import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/eskom/data/models/eskom_model.dart';
import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tModel = EskomModel.empty();

  test('should be a subclass of [Eskom] entity', () {
    //Arrange
    //Act
    //Assert
    expect(tModel, isA<Eskom>());
  });

  final tJson = fixture('eskom.json');
  final tMap = jsonDecode(tJson) as DataMap;

  group('fromMap', () {
    test('should return a [EskomModel] with the correct data', () {
      //Arrange -- done
      //Act
      final result = EskomModel.fromMap(tMap);
      expect(result, equals(tModel));
    });
  });

  group('fromJson', () {
    test('should return [EskomModel] withe the right data', () {
      //Act
      final result = EskomModel.fromJson(tJson);
      expect(result, equals(tModel));
    });
  });
}
