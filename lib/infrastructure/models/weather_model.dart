class Weather {
  final String cityName;
  final double temp;
  final String condition;
  final int humidity;
  final int maxTemp;
  final int minTemp;
  final double feelsLike;

  Weather({
    required this.cityName, 
    required this.temp, 
    required this.condition, 
    required this.humidity,
    required this.maxTemp,
    required this.minTemp,
    required this.feelsLike,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] as String, 
      temp: (json['main']['temp'] as num).toDouble() , 
      condition: json['weather'][0]['main'] as String,
      humidity: (json['main']['humidity'] as num).toInt(),
      maxTemp: (json['main']['temp_max'] as num ).toInt(),
      minTemp: (json['main']['temp_min'] as num ).toInt(),
      feelsLike: (json['main']['feels_like'] as num).toDouble()
    );
  }
}