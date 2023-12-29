import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';

abstract class EskomAuthRepo {
  const EskomAuthRepo();

  Future<(Exception, List<Eskom>)> getStatus();
}
