import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MapService {
  static const BASE_URL = 'https://tile.openweathermap.org/map';
  final String apiKey = '36a6c7e581c377d84a25f5a91f100078';
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

  Future<String> getWeatherMap(int z, double longitude, double latitude, String layer) async {
    int tileX = ((longitude + 180) / 360 * pow(2, z)).floor();
    int tileY = ((1 - log(tan(latitude * pi / 180) + 1 / cos(latitude * pi / 180)) / pi) / 2 * pow(2, z)).floor();

    if (tileX < 0 || tileY < 0) throw Exception('Failed. Tiles values are not correct');

    final Uri uri = Uri.parse('$BASE_URL/$layer/$z/$tileX/$tileY.png?appid=$apiKey');
    print('URL DE LA IMAGEN: $uri');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return uri.toString();
      } else {
        throw Exception('Failed loading map: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching map: $e');
    }
    // if (response.statusCode == 200) {
    //   return response.body;
    // } else {
    //   throw Exception('Failed loading the weather map');
    // }
  }
  // Future<String> getWeatherMap(int z, int x, int y, String layer) async {
  //   final response = await http.get(Uri.parse('$BASE_URL/$layer/$z/$x/$y.png?appid=$apiKey'));

  //   if (response.statusCode == 200) {
  //     return response.body;
  //   } else {
  //     throw Exception('Failed loading the weather map');
  //   }
  // }
}

// Future<File> _saveImage(Uint8List bytes, String layer) async {
//   final directory = await getApplicationDocumentsDirectory();
//   final file = File('${directory.path}/$layer.png');
//   await file.writeAsBytes(bytes);
//   return file;
// }