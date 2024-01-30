import 'package:gs_orange/src/loadshedding/data/data_sources/remote_data_source.dart';
import 'package:gs_orange/src/loadshedding/domain/repository/loadshedding_repository.dart';
import 'package:gs_orange/src/loadshedding/domain/usecases/get_current_stage.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks(
  [
    LoadSheddingRepository,
    LoadSheddingRemoteDataSource,
    GetCurrentStageUsecase,
  ],
  customMocks: [MockSpec<http.Client>(as: #MockHttpClient)],
)
void main() {}
