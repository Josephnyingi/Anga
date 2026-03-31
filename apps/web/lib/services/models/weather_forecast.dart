/// 🌦️ Weather Forecast Model
///
/// Type-safe model for weather forecast data returned from the API.
class WeatherForecastModel {
  final String source;
  final String date;
  final String location;
  final double temperaturePrediction;
  final double rainPrediction;
  final String? error;

  WeatherForecastModel({
    required this.source,
    required this.date,
    required this.location,
    required this.temperaturePrediction,
    required this.rainPrediction,
    this.error,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      source: json['source'] ?? 'unknown',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      temperaturePrediction: (json['temperature_prediction'] ?? 0.0).toDouble(),
      rainPrediction: (json['rain_prediction'] ?? 0.0).toDouble(),
      error: json['error'],
    );
  }

  factory WeatherForecastModel.fromLiveWeather(Map<String, dynamic> json) {
    return WeatherForecastModel(
      source: 'live',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      temperaturePrediction: (json['temperature_max'] ?? 0.0).toDouble(),
      rainPrediction: (json['rain_sum'] ?? 0.0).toDouble(),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'date': date,
      'location': location,
      'temperature_prediction': temperaturePrediction,
      'rain_prediction': rainPrediction,
      if (error != null) 'error': error,
    };
  }

  bool get hasError => error != null;

  String get temperatureString => '${temperaturePrediction.toStringAsFixed(1)}°C';
  String get rainfallString => '${rainPrediction.toStringAsFixed(1)}mm';

  String get weatherCondition {
    if (rainPrediction > 10) return '🌧️ Heavy Rain';
    if (rainPrediction > 5) return '🌦️ Light Rain';
    if (temperaturePrediction > 30) return '☀️ Hot';
    if (temperaturePrediction > 25) return '🌤️ Warm';
    if (temperaturePrediction > 20) return '🌥️ Mild';
    if (temperaturePrediction > 15) return '⛅ Cool';
    return '❄️ Cold';
  }

  @override
  String toString() =>
      'WeatherForecastModel(source: $source, date: $date, location: $location, '
      'temperature: $temperatureString, rainfall: $rainfallString)';
}

/// 🌡️ Weather Data Point for Charts
class WeatherDataPoint {
  final double day;
  final double temperature;
  final double rain;

  WeatherDataPoint({
    required this.day,
    required this.temperature,
    required this.rain,
  });

  factory WeatherDataPoint.fromMap(Map<String, dynamic> map) {
    return WeatherDataPoint(
      day: (map['day'] ?? 0.0).toDouble(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      rain: (map['rain'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'day': day,
        'temperature': temperature,
        'rain': rain,
      };
}
