const kDefaultAvatar = 'https://images.freeimages'
    '.com/fic/images/icons/573/must_have/256/user.png';

const kBaseUrl = 'developer.sepush.co.za';
const kToken = '4ECF9AD1-0E704B10-BF575234-9524D598';
var kRegion = '';

//  New method
class Urls {
  static const String baseUrl = 'https://developer.sepush.co.za/2.0/status';
  static const String apiKey = '4ECF9AD1-0E704B10-BF575234-9524D598';
  static const String testJhb =
      'area?id=eskde-10-fourwaysext10cityofjohannesburggauteng&test=current';
  static String currentStageByName(String city) =>
      '$baseUrl/$testJhb&appid=$apiKey';
}
