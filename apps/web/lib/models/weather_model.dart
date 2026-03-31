/// 🌤️ Weather Model
class WeatherModel {
  final String location;
  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final double rainfall;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String? source;

  WeatherModel({
    required this.location,
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.rainfall,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    this.source,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      temperatureMax: (json['temperature_max'] ?? json['temperature'] ?? 0.0).toDouble(),
      temperatureMin: (json['temperature_min'] ?? 0.0).toDouble(),
      rainfall: (json['rain_sum'] ?? json['rain'] ?? json['rainfall'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      windSpeed: (json['wind_speed'] ?? json['windspeed'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? _deriveCondition(
        (json['temperature_max'] ?? json['temperature'] ?? 0.0).toDouble(),
        (json['rain_sum'] ?? json['rain'] ?? 0.0).toDouble(),
      ),
      source: json['source'],
    );
  }

  static String _deriveCondition(double temp, double rain) {
    if (rain > 10) return 'Heavy Rain';
    if (rain > 5) return 'Light Rain';
    if (temp > 30) return 'Hot';
    if (temp > 25) return 'Warm';
    if (temp > 15) return 'Mild';
    return 'Cool';
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'date': date,
        'temperature_max': temperatureMax,
        'temperature_min': temperatureMin,
        'rain_sum': rainfall,
        'humidity': humidity,
        'wind_speed': windSpeed,
        'condition': condition,
        if (source != null) 'source': source,
      };

  String get temperatureString => '${temperatureMax.toStringAsFixed(1)}°C';
  String get rainfallString => '${rainfall.toStringAsFixed(1)}mm';

  String get conditionEmoji {
    if (rainfall > 10) return '🌧️';
    if (rainfall > 5) return '🌦️';
    if (temperatureMax > 30) return '☀️';
    if (temperatureMax > 25) return '🌤️';
    if (temperatureMax > 20) return '🌥️';
    if (temperatureMax > 15) return '⛅';
    return '❄️';
  }

  @override
  String toString() =>
      'WeatherModel(location: $location, date: $date, temp: $temperatureString, rain: $rainfallString)';
}
