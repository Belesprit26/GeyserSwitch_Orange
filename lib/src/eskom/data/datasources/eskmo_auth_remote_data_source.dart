import 'package:gs_orange/src/auth/data/models/eskom_model.dart';

abstract class EskomAuthRemoteDataSource {
  //
  Future<List<EskomModel>> getEskom();
}
