import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/weather_icon_widget.dart';
import '../../../../features/settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../weather/domain/entities/forecast_entity.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecastEntity> dailyList;
  final SettingsViewModel settingsVM;

  const DailyForecastWidget({
    super.key,
    required this.dailyList,
    required this.settingsVM,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyList.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                '10-Day Forecast',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyList.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white.withOpacity(0.08),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final item = dailyList[index];
              return _DailyForecastTile(
                forecast: item,
                settingsVM: settingsVM,
                isToday: index == 0,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DailyForecastTile extends StatefulWidget {
  final DailyForecastEntity forecast;
  final SettingsViewModel settingsVM;
  final bool isToday;

  const _DailyForecastTile({
    required this.forecast,
    required this.settingsVM,
    required this.isToday,
  });

  @override
  State<_DailyForecastTile> createState() => _DailyForecastTileState();
}

class _DailyForecastTileState extends State<_DailyForecastTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(widget.forecast.timestamp * 1000);
    final dayName = widget.isToday ? 'Today' : DateFormat('EEEE').format(date);
    final dateStr = DateFormat('MMM d').format(date);
    
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(widget.forecast.sunrise * 1000);
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(widget.forecast.sunset * 1000);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool showProgressBar = screenWidth > 360;

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Column(
          children: [
            // Closed Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Day details
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Weather icon and description
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      WeatherIconWidget(
                        condition: widget.forecast.condition,
                        iconCode: widget.forecast.iconCode,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.forecast.condition,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Min / Max temperature
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.settingsVM.formatTemperature(widget.forecast.tempMin),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      if (showProgressBar) ...[
                        const SizedBox(width: 6),
                        // Colored progress-style indicator line
                        Container(
                          width: 30,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        widget.settingsVM.formatTemperature(widget.forecast.tempMax),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Expandable details with smooth transition
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary: Expect ${widget.forecast.description} throughout the day, with temperatures peaking at ${widget.settingsVM.formatTemperature(widget.forecast.tempMax)}.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildExpandedMetric('Wind', widget.settingsVM.formatWindSpeed(widget.forecast.windSpeed)),
                              _buildExpandedMetric('Humidity', '${widget.forecast.humidity}%'),
                              _buildExpandedMetric('Pressure', widget.settingsVM.formatPressure(widget.forecast.pressure)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildExpandedMetric('Sunrise', DateFormat('h:mm a').format(sunriseTime)),
                              _buildExpandedMetric('Sunset', DateFormat('h:mm a').format(sunsetTime)),
                              _buildExpandedMetric('Rain Prob.', '${(widget.forecast.rainProbability * 100).toStringAsFixed(0)}%'),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
