import 'package:gs_orange/src/eskom/data/datasources/eskmo_auth_remote_data_source.dart';
import 'package:gs_orange/src/eskom/data/repos/eskom_auth_repo_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockEskomAuthRemoteDataSource extends Mock
    implements EskomAuthRemoteDataSource {}

void main() {
  late EskomAuthRemoteDataSource remoteDataSource;
  late EskomAuthRepoImpl repoImpl;
  
  setUp((){
    repoImpl = EskomAuthRepoImpl(remoteDataSource);
  });
  //
}
