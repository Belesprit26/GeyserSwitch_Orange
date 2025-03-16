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
    Map<String, String> headers = {
      'token': kToken,
      'contentType': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

    var request = http.Request(
        'GET', Uri.parse('https://developer.sepush.co.za/business/2.0/status'));
    var request2 = http.Request('GET',
        Uri.parse('https://developer.sepush.co.za/business/2.0/api_allowance'));

    request.headers.addAll(headers);
    request2.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    http.StreamedResponse response2 = await request2.send();

    var data;
    if (response.statusCode == 200) {
      await response.stream.bytesToString().then((value) {
        print(value);
        data = value;
      });
      await response2.stream.bytesToString().then((allowance) {
        print(allowance);
      });
      return LoadSheddingModel.fromJson(json.decode(data));
    } else {
      print(response.reasonPhrase);
      throw ServersException();
    }
  }
}
