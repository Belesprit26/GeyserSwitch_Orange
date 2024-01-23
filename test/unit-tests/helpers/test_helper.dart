import 'package:gs_orange/src/loadshedding/domain/repository/loadshedding_repositiory.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks(
  [LoadSheddingRepository],
  customMocks: [MockSpec<http.Client>(as: #MockHttpClient)],
)
void main() {}
