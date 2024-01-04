import 'dart:convert';

import 'package:gs_orange/core/utils/constants.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/eskom/data/models/eskom_model.dart';
import 'package:http/http.dart' as http;

abstract class EskomAuthRemoteDataSource {
  //
  Future<List<EskomModel>> getEskom();
}

const kGetEskomEndpoint = '/business/2.0/status';

class EskomAuthRemoteDataSrcImpl implements EskomAuthRemoteDataSource {
  const EskomAuthRemoteDataSrcImpl(this._client);

  final http.Client _client;

  @override
  Future<List<EskomModel>> getEskom() async {
    final response = await _client.get(
      Uri.https(
        kBaseUrl,
        kGetEskomEndpoint,
      ),
      /*headers: {'token': kToken},*/
    );
    //Deserialization
    return List<DataMap>.from(jsonDecode(response.body) as List)
        .map((eskomData) => EskomModel.fromMap(eskomData))
        .toList();
  }
}
