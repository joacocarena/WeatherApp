import 'dart:convert';

import '../models/extended_weather_model.dart';
import 'package:http/http.dart' as http;

class ExtendedWeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast';
  final String apiKey = '85d3ab4964e32bacea6dc485f144e1a7';
  final String cityName;

  ExtendedWeatherService({required this.cityName});

  Future<List<Map<String, dynamic>>> fetchWeatherDataPerDay() async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric&cnt=40'));
    
    if (response.statusCode == 200) {
      
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> periodDataList = data['list'];
      final Map<int, List<Map<String, dynamic>>> dailyDataByDay = {};
      for (final actualPeriodData in periodDataList) {
        final int timeStamp = actualPeriodData['dt'] as int;
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(timeStamp*1000);
        final int day = date.day;
        if (!dailyDataByDay.containsKey(day)) dailyDataByDay[day] = [];
        dailyDataByDay[day]!.add({
          'temp': (actualPeriodData['main']['temp'] as num).toDouble(),
          'condition': (actualPeriodData['weather'][0]['main'] as String),
          'maxTemp': (actualPeriodData['main']['temp_max'] as num).toDouble(),
          'minTemp': (actualPeriodData['main']['temp_min'] as num).toDouble(),
          'feelsLike': (actualPeriodData['main']['feels_like'] as num).toDouble(),
        });
      }
      List<Map<String, dynamic>> dailyWeatherData = [];
      dailyDataByDay.forEach((day, dailyData) {
        final averageData = {
          'temp': dailyData.map<double>((data) => data['temp'] as double).reduce((a, b) => a + b) / dailyData.length,
          'condition': _calculateMostFrequentCondition(dailyData),
          'maxTemp': dailyData.map<double>((data) => data['maxTemp'] as double).reduce((a, b) => a + b) / dailyData.length,
          'minTemp': dailyData.map<double>((data) => data['minTemp'] as double).reduce((a, b) => a + b) / dailyData.length,
          'feelsLike': dailyData.map<double>((data) => data['feelsLike'] as double).reduce((a, b) => a + b) / dailyData.length,
        };
        dailyWeatherData.add(averageData);
      });
      print('xtndd wather: $dailyWeatherData');
      return dailyWeatherData;
    } else {
      print('error loading the data for the day');
      throw Exception('failed in weather service');
    }
  }

  String _calculateMostFrequentCondition(List<Map<String, dynamic>> data) {
    final conditionCounts = <String, int> {};

    for (final i in data) {
      final condition = i['condition'].toString();
      conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
    }
    return conditionCounts.entries.fold('', (previousValue, element) => element.value > (conditionCounts[previousValue] ?? 0) ? element.key : previousValue);
  }

  Future<ExtendedWeather> getExtendedWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    try {
      if (response.statusCode == 200) {
        print('Body extended. weather.: ${response.body}');
        return ExtendedWeather.fromJson(jsonDecode(response.body));
      }
      return ExtendedWeather.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception();
    }
  }
}