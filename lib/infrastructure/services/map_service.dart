import 'package:http/http.dart' as http;

class MapService {
  static const BASE_URL = 'https://tile.openweathermap.org/map';
  final String apiKey = '85d3ab4964e32bacea6dc485f144e1a7';
  final int? z;
  final double? longitude;
  final double? latitude;
  final String? layer;

  MapService({
    this.z = 0, 
    this.longitude = 0, 
    this.latitude = 0, 
    this.layer = ''
  });

  Future<String> getWeatherMap(int z, int x, int y, String layer) async {
    final response = await http.get(Uri.parse('$BASE_URL/$layer/$z/$x/$y.png?appid=$apiKey'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed loading the weather map');
    }
  }
}