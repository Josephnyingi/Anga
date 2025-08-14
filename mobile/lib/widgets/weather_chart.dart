import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class WeatherChart extends StatelessWidget {
  final List<FlSpot> tempSpots;
  final List<BarChartGroupData> rainBars;
  final List<String> forecastDates;

  const WeatherChart({
    super.key,
    required this.tempSpots,
    required this.rainBars,
    required this.forecastDates,
  });

  @override
  Widget build(BuildContext context) {
    // Debug information for platform-specific issues
    print("📊 [WeatherChart] Building chart on ${Platform.operatingSystem}");
    print("📊 [WeatherChart] Temp spots: ${tempSpots.length}");
    print("📊 [WeatherChart] Rain bars: ${rainBars.length}");
    print("📊 [WeatherChart] Forecast dates: ${forecastDates.length}");
    
    // Check if we have data to display
    if (tempSpots.isEmpty && rainBars.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No chart data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Platform: ${Platform.operatingSystem}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // **Rainfall Bar Chart**
          BarChart(
            BarChartData(
              barGroups: rainBars,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      return index < forecastDates.length
                          ? Text(forecastDates[index], style: const TextStyle(fontSize: 12))
                          : const Text("");
                    },
                  ),
                ),
              ),
            ),
          ),

          // **Temperature Line Chart (Overlaying the Bars)**
          LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: tempSpots,
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                      // ignore: deprecated_member_use
                      show: true, color: Colors.redAccent.withOpacity(0.3)),
                ),
              ],
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
