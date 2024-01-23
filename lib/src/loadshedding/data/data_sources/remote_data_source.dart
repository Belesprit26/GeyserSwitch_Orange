import 'dart:convert';

import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/utils/constants.dart';
import 'package:http/http.dart' as http;

import 'package:gs_orange/src/loadshedding/data/models/loadshedding_model.dart';

abstract class LoadSheddingRemoteDataSource {
  Future<LoadSheddingModel> getCurrentStage(String cityName);
}

class LoadSheddingRemoteDataSourceImpl extends LoadSheddingRemoteDataSource {
  final http.Client client;
  LoadSheddingRemoteDataSourceImpl({required this.client});

  @override
  Future<LoadSheddingModel> getCurrentStage(String cityName) async {
    final response =
        await client.get(Uri.parse(Urls.currentStageByName(cityName)));

    if (response.statusCode == 200) {
      return LoadSheddingModel.fromJson(json.decode(response.body));
    } else {
      throw ServersException();
    }
  }
}
