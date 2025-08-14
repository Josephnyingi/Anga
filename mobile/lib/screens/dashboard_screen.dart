// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/weather_services.dart';
import '../services/live_weather_service.dart';
import '../utils/app_state.dart'; // ✅ new global state

String formatApiDate(DateTime date) {
  // Example: returns 'yyyy-MM-dd'
  return DateFormat('yyyy-MM-dd').format(date);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> tempSpots = [];
  List<BarChartGroupData> rainBars = [];
  List<String> forecastDates = [];
  Map<String, dynamic> currentWeather = {};
  Map<String, dynamic> liveWeather = {};
  bool isLoading = true;

  // Track previous settings
  String _prevLocation = AppState.selectedLocation;
  DateTime _prevStartDate = AppState.startDate;
  DateTime _prevEndDate = AppState.endDate;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSettingsChange();
    });
  }

  void _checkForSettingsChange() {
    if (_prevLocation != AppState.selectedLocation ||
        _prevStartDate != AppState.startDate ||
        _prevEndDate != AppState.endDate) {
      _prevLocation = AppState.selectedLocation;
      _prevStartDate = AppState.startDate;
      _prevEndDate = AppState.endDate;

      fetchWeather();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔄 Settings changed. Refreshing data...")),
      );
    }
  }

  Future<void> fetchWeather() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await _fetchLiveWeather();
    await _fetchCurrentWeather();
    await _fetchForecast();

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchLiveWeather() async {
    try {
      final data = await LiveWeatherService.getLiveWeather(AppState.selectedLocation.toLowerCase());
      if (mounted) setState(() => liveWeather = data);
    } catch (e) {
      print("❌ Live weather fetch error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Could not load live weather")),
        );
      }
    }
  }

  Future<void> _fetchCurrentWeather() async {
    try {
      final date = formatApiDate(DateTime.now());
      final data = await WeatherService.getWeather(date, AppState.selectedLocation);
      if (mounted) setState(() => currentWeather = data);
    } catch (e) {
      print("❌ Predicted weather fetch error: $e");
    }
  }

  Future<void> _fetchForecast() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();

      for (DateTime date = AppState.startDate;
          date.isBefore(AppState.endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final data = await WeatherService.getWeather(formatApiDate(date), AppState.selectedLocation);
        forecastDates.add(DateFormat('d/M').format(date));
        weatherData.add({
          "day": weatherData.length.toDouble(),
          "temperature": data['temperature_prediction'],
          "rain": data['rain_prediction'],
        });
      }

      if (mounted) {
        setState(() {
          tempSpots = weatherData.map((e) => FlSpot(e["day"], e["temperature"])).toList();
          rainBars = weatherData.map((e) => BarChartGroupData(
            x: e["day"].toInt(),
            barRods: [
              BarChartRodData(
                toY: e["rain"],
                width: 10,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              )
            ]
          )).toList();
        });
      }
    } catch (e) {
      print("❌ Forecast fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Weather Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.orangeAccent : Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchWeather),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ LIVE WEATHER SECTION
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: isDarkMode ? Colors.black87 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Live Weather in ${AppState.selectedLocation}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black87
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[800] : Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.thermostat, color: Colors.redAccent, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Temperature",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${liveWeather['temperature_max'] ?? '--'}°C",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.water_drop, color: Colors.blueAccent, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Rainfall",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${liveWeather['rain_sum'] ?? '--'}mm",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "Date: ${liveWeather['date'] ?? '--'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🌡️ Temperature Forecast Chart
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: isDarkMode ? Colors.black87 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.thermostat, color: Colors.redAccent, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "Temperature Forecast",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 280,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 5,
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= forecastDates.length) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            forecastDates[index],
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 5,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}°C',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                                    width: 1,
                                  ),
                                ),
                                minX: 0,
                                maxX: (forecastDates.length - 1).toDouble(),
                                minY: 0,
                                maxY: tempSpots.isNotEmpty ? (tempSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5) : 30,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: tempSpots,
                                    isCurved: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.redAccent,
                                        Colors.orangeAccent,
                                        Colors.yellowAccent,
                                      ],
                                    ),
                                    barWidth: 4,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: Colors.redAccent,
                                          strokeWidth: 3,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.redAccent.withOpacity(0.3),
                                          Colors.orangeAccent.withOpacity(0.1),
                                          Colors.yellowAccent.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🌧️ Rainfall Forecast Chart
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: isDarkMode ? Colors.black87 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.water_drop, color: Colors.blueAccent, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "Rainfall Forecast",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 280,
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 2,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                alignment: BarChartAlignment.spaceAround,
                                maxY: rainBars.isNotEmpty ? (rainBars.map((e) => e.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 2) : 10,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBorder: BorderSide(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${rod.toY.toStringAsFixed(1)}mm',
                                        TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= forecastDates.length) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            forecastDates[index],
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 2,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}mm',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                                    width: 1,
                                  ),
                                ),
                                barGroups: rainBars.map((barGroup) {
                                  return BarChartGroupData(
                                    x: barGroup.x,
                                    barRods: [
                                      BarChartRodData(
                                        toY: barGroup.barRods.first.toY,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue[400]!,
                                            Colors.blue[600]!,
                                            Colors.blue[800]!,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: rainBars.isNotEmpty ? (rainBars.map((e) => e.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 2) : 10,
                                          color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

