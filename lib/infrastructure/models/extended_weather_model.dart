class ExtendedWeather {
  final double temp;
  final String condition;
  final double maxTemp;
  final double minTemp;
  final double feelsLike;

  ExtendedWeather({
    required this.temp, 
    required this.condition, 
    required this.maxTemp, 
    required this.minTemp, 
    required this.feelsLike
  });

  ExtendedWeather copyWith({
    final double? temp,
    final String? condition,
    final double? maxTemp,
    final double? minTemp,
    final double? feelsLike,
  }) {
    return ExtendedWeather(
      temp: temp ?? this.temp, 
      condition: condition ?? this.condition, 
      maxTemp: maxTemp ?? this.maxTemp, 
      minTemp: minTemp ?? this.minTemp, 
      feelsLike: feelsLike ?? this.feelsLike
    );
  }

  factory ExtendedWeather.fromJson(Map<String, dynamic> json) {
    
    final firstItem = json['list'][0];
    
    return ExtendedWeather(
      temp: (firstItem['main']['temp'] as num).toDouble(),  
      condition: firstItem['weather'][0]['main'] as String, 
      maxTemp: (firstItem['main']['temp_max'] as num).toDouble(), 
      minTemp: (firstItem['main']['temp_min'] as num).toDouble(), 
      feelsLike: (firstItem['main']['feels_like'] as num).toDouble()
    );
  }
}