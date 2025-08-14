import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/weather_provider.dart';
import '../utils/api_config.dart';

class EnhancedWeatherCard extends StatelessWidget {
  final String title;
  final String location;
  final Map<String, dynamic> weatherData;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;

  const EnhancedWeatherCard({
    super.key,
    required this.title,
    required this.location,
    required this.weatherData,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.white, Colors.blue[50]!],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDarkMode),
                  const SizedBox(height: 16),
                  if (isLoading) _buildLoadingIndicator(),
                  if (error != null) _buildErrorWidget(context, error!),
                  if (!isLoading && error == null) _buildWeatherContent(context, isDarkMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          _getWeatherIcon(),
          size: 32,
          color: isDarkMode ? Colors.orangeAccent : Colors.blueAccent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading weather data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getUserFriendlyError(error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, bool isDarkMode) {
    final temperature = weatherData['temperature'] ?? weatherData['temperature_max'] ?? weatherData['temperature_prediction'];
    final rainfall = weatherData['rain'] ?? weatherData['rain_sum'] ?? weatherData['rain_prediction'];
    final date = weatherData['date'];

    return Column(
      children: [
        if (temperature != null) ...[
          Row(
            children: [
              Icon(
                Icons.thermostat,
                color: _getTemperatureColor(temperature),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${temperature.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getTemperatureColor(temperature),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (rainfall != null) ...[
          Row(
            children: [
              Icon(
                Icons.water_drop,
                color: Colors.blue[400],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${rainfall.toStringAsFixed(1)} mm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (date != null) ...[
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                date.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _buildWeatherDescription(temperature, rainfall),
      ],
    );
  }

  Widget _buildWeatherDescription(dynamic temperature, dynamic rainfall) {
    String description = 'Weather conditions are normal';
    Color descriptionColor = Colors.green;

    if (temperature != null) {
      final temp = temperature.toDouble();
      if (temp > 30) {
        description = 'Hot weather conditions';
        descriptionColor = Colors.red;
      } else if (temp < 10) {
        description = 'Cold weather conditions';
        descriptionColor = Colors.blue;
      }
    }

    if (rainfall != null) {
      final rain = rainfall.toDouble();
      if (rain > 20) {
        description = 'Heavy rainfall expected';
        descriptionColor = Colors.blue;
      } else if (rain > 5) {
        description = 'Light to moderate rain';
        descriptionColor = Colors.orange;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: descriptionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: descriptionColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getDescriptionIcon(description),
            color: descriptionColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: descriptionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    final temperature = weatherData['temperature'] ?? weatherData['temperature_max'] ?? weatherData['temperature_prediction'];
    final rainfall = weatherData['rain'] ?? weatherData['rain_sum'] ?? weatherData['rain_prediction'];

    if (rainfall != null && rainfall > 5) {
      return Icons.umbrella;
    } else if (temperature != null) {
      final temp = temperature.toDouble();
      if (temp > 25) {
        return Icons.wb_sunny;
      } else if (temp > 15) {
        return Icons.cloud;
      } else {
        return Icons.ac_unit;
      }
    }
    return Icons.cloud;
  }

  IconData _getDescriptionIcon(String description) {
    if (description.contains('Hot')) return Icons.wb_sunny;
    if (description.contains('Cold')) return Icons.ac_unit;
    if (description.contains('rain')) return Icons.water_drop;
    return Icons.info_outline;
  }

  Color _getTemperatureColor(dynamic temperature) {
    if (temperature == null) return Colors.grey;
    
    final temp = temperature.toDouble();
    if (temp > 30) return Colors.red;
    if (temp > 25) return Colors.orange;
    if (temp > 15) return Colors.green;
    if (temp > 5) return Colors.blue;
    return Colors.purple;
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('Location not found')) {
      return 'Location not found. Please check the spelling.';
    } else if (error.contains('Network error')) {
      return 'Network connection issue. Please check your internet.';
    } else if (error.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.contains('rate limit')) {
      return 'Too many requests. Please wait a moment.';
    } else {
      return 'Unable to load weather data. Please try again.';
    }
  }
} 