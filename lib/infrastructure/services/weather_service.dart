import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey = '85d3ab4964e32bacea6dc485f144e1a7';
  
  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));
    
    if (response.statusCode == 200) {
      print(response.body);
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed loading the data');
    }
  }

  Future<String> getCity() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placeMarks[0].locality;
    return city ?? '';
  }
}