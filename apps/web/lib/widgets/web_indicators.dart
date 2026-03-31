import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'web_animations.dart';

/// 📊 **Web Indicators and Status Components**
/// 
/// Enhanced indicators optimized for web display
class WebIndicators {
  // Status indicator
  static Widget statusIndicator({
    required String status,
    String? message,
    Color? color,
    IconData? icon,
  }) {
    final statusColor = color ?? _getStatusColor(status);
    final statusIcon = icon ?? _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          if (message != null) ...[
            const SizedBox(width: 6),
            Text(
              message,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Progress indicator
  static Widget progressIndicator({
    required double progress,
    String? label,
    Color? color,
    double height = 8,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Colors.blue,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Circular progress indicator
  static Widget circularProgress({
    required double progress,
    String? label,
    Color? color,
    double size = 60,
    double strokeWidth = 6,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: strokeWidth,
                color: color ?? Colors.blue,
                backgroundColor: Colors.grey.withOpacity(0.2),
              ),
              Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // Badge indicator
  static Widget badge({
    required String text,
    Color? color,
    Color? textColor,
    double? fontSize,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Dot indicator
  static Widget dotIndicator({
    required bool isActive,
    Color? activeColor,
    Color? inactiveColor,
    double size = 8,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive
            ? (activeColor ?? Colors.blue)
            : (inactiveColor ?? Colors.grey.withOpacity(0.3)),
        shape: BoxShape.circle,
      ),
    );
  }

  // Pulse indicator
  static Widget pulseIndicator({
    required bool isActive,
    Color? color,
    double size = 12,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive
                ? (color ?? Theme.of(context).primaryColor)
                : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (color ?? Theme.of(context).primaryColor)
                          .withOpacity(0.3 * _pulseAnimation.value),
                      blurRadius: 8 * _pulseAnimation.value,
                      spreadRadius: 2 * _pulseAnimation.value,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }

  // Connection status indicator
  static Widget connectionStatus({
    required bool isConnected,
    String? message,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 6),
          Text(
            message,
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  // Temperature indicator
  static Widget temperatureIndicator({
    required double temperature,
    String? unit,
    Color? color,
    double size = 24,
  }) {
    final tempColor = color ?? _getTemperatureColor(temperature);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.thermostat,
          color: tempColor,
          size: size,
        ),
        const SizedBox(width: 4),
        Text(
          '${temperature.toStringAsFixed(1)}${unit ?? '°C'}',
          style: TextStyle(
            color: tempColor,
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Weather condition indicator
  static Widget weatherCondition({
    required String condition,
    double size = 32,
  }) {
    return Icon(
      _getWeatherIcon(condition),
      size: size,
      color: _getWeatherColor(condition),
    );
  }

  // Helper methods
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'online':
      case 'active':
        return Colors.green;
      case 'warning':
      case 'pending':
        return Colors.orange;
      case 'error':
      case 'offline':
      case 'inactive':
        return Colors.red;
      case 'info':
      case 'loading':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'online':
      case 'active':
        return Icons.check_circle;
      case 'warning':
      case 'pending':
        return Icons.warning;
      case 'error':
      case 'offline':
      case 'inactive':
        return Icons.error;
      case 'info':
      case 'loading':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  static Color _getTemperatureColor(double temperature) {
    if (temperature < 0) return Colors.blue;
    if (temperature < 10) return Colors.cyan;
    if (temperature < 20) return Colors.green;
    if (temperature < 30) return Colors.yellow;
    if (temperature < 40) return Colors.orange;
    return Colors.red;
  }

  static IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.grain;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      case 'stormy':
      case 'thunderstorm':
        return Icons.flash_on;
      case 'foggy':
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy;
    }
  }

  static Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'snowy':
      case 'snow':
        return Colors.cyan;
      case 'stormy':
      case 'thunderstorm':
        return Colors.purple;
      case 'foggy':
      case 'fog':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}

// Pulse animation controller
final AnimationController _pulseController = AnimationController(
  duration: const Duration(seconds: 1),
  vsync: _PulseTickerProvider(),
);

final Animation<double> _pulseAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(CurvedAnimation(
  parent: _pulseController,
  curve: Curves.easeInOut,
));

class _PulseTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
