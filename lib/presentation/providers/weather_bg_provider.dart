import 'package:flutter/material.dart';

class WeatherBgProvider extends ChangeNotifier {
  bool? isDay;
  String? weather;

  WeatherBgProvider({this.weather, this.isDay});

  Color get setBgColor {

    late Color finalBgColor;

    
    if (isDay == null) return Colors.black12;
    if (isDay!) { //? If it's day time...
      
      switch (weather?.toLowerCase()) {
        
        case "clear":
          finalBgColor = Colors.limeAccent.shade100;
          break;
        case "clouds":
          finalBgColor = Colors.grey.shade400;
          break;
        case "rain":
          finalBgColor = Colors.blueGrey.shade200;
          break;
        case "storm":
          finalBgColor = Colors.blueGrey.shade300;
        default:
          finalBgColor = Colors.grey.shade300;
          break;
      }
    }

    if (isDay == false) { //? if it's night time...
      switch (weather?.toLowerCase()) {
        
        case "clear":
          finalBgColor = Colors.indigo;
          break;
        case "clouds":
          finalBgColor = Colors.black87;
          break;
        case "rain":
          finalBgColor = Colors.orange.shade100;
          break;
        default:
          finalBgColor = Colors.indigo.shade100;
          break;
      }
    }

    return finalBgColor;

  }

  void updateWeather (bool day, String weatherCond) {
    isDay = day;
    weather = weatherCond;
    notifyListeners();
  }

}

// class Time {
//   late DateTime now = DateTime.now();
// }