import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/weather_icon_widget.dart';
import '../../../../features/settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../weather/domain/entities/forecast_entity.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecastEntity> hourlyList;
  final SettingsViewModel settingsVM;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyList,
    required this.settingsVM,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) return const SizedBox.shrink();

    // Take the next 12 hours for a clean chart
    final displayList = hourlyList.take(12).toList();

    return GlassContainer(
      borderRadius: 24.0,
      bgOpacity: 0.05,
      borderOpacity: 0.08,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.query_builder_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // fl_chart interactive temperature graph
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final val = displayList[spot.spotIndex].temp;
                        return LineTooltipItem(
                          settingsVM.formatTemperature(val),
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: displayList.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.temp);
                    }).toList(),
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: Colors.white.withOpacity(0.9),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.0),
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
          
          const SizedBox(height: 16),
          
          // Horizontal scrolling details cards
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                final time = DateTime.fromMillisecondsSinceEpoch(item.timestamp * 1000);
                final formattedHour = DateFormat('h a').format(time);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        index == 0 ? 'Now' : formattedHour,
                        style: TextStyle(
                          color: index == 0 ? Colors.white : Colors.white60,
                          fontSize: 13,
                          fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      WeatherIconWidget(
                        condition: item.condition,
                        iconCode: item.iconCode,
                        size: 32,
                      ),
                      Column(
                        children: [
                          Text(
                            settingsVM.formatTemperature(item.temp),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.rainProbability > 0.15)
                            Text(
                              '${(item.rainProbability * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
