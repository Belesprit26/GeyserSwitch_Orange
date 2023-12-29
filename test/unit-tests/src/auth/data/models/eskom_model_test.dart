import 'package:flutter_test/flutter_test.dart';
import 'package:gs_orange/src/auth/data/models/eskom_model.dart';
import 'package:gs_orange/src/auth/domain/entities/eskom.dart';

void main() {
  const tModel = EskomModel.empty();

  test('should be a subclass of [Eskom] entity', () {
    //Arrange
    //Act
    //Assert
    expect(tModel, isA<Eskom>());
  });

  group('fromMap', () {
    test('should return a [EskomModel] with the correct data', () {
      //Arrange
      //Act
      //final result = EskomModel.fromMap(map);
    });
  });
}
