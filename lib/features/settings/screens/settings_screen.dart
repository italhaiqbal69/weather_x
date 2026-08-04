import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/weather_background_widget.dart';
import '../../../../core/theme/theme_manager.dart';
import '../presentation/viewmodels/settings_viewmodel.dart';
import '../../weather/presentation/viewmodels/weather_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = Provider.of<SettingsViewModel>(context);
    final weatherVM = Provider.of<WeatherViewModel>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: WeatherBackgroundWidget(
        themeType: WeatherThemeType.night, // Midnight theme style for settings
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Units Settings Header
              _buildSectionHeader('Preferences & Units'),
              const SizedBox(height: 10),
              
              GlassContainer(
                borderRadius: 20,
                bgOpacity: 0.05,
                borderOpacity: 0.08,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Temperature Unit Choice
                    _buildDropdownRow<TemperatureUnit>(
                      icon: Icons.thermostat_rounded,
                      title: 'Temperature Unit',
                      value: settingsVM.tempUnit,
                      items: TemperatureUnit.values,
                      labelBuilder: (u) => u == TemperatureUnit.celsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                      selectedLabelBuilder: (u) => u == TemperatureUnit.celsius ? '°C' : '°F',
                      onChanged: (val) {
                        if (val != null) {
                          settingsVM.setTemperatureUnit(val);
                          weatherVM.loadAllWeatherData(forceRefresh: false); // Reload to format correctly
                        }
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    
                    // Wind Unit Choice
                    _buildDropdownRow<WindSpeedUnit>(
                      icon: Icons.air_rounded,
                      title: 'Wind Speed Unit',
                      value: settingsVM.windUnit,
                      items: WindSpeedUnit.values,
                      labelBuilder: (u) {
                        switch (u) {
                          case WindSpeedUnit.kmh: return 'Kilometers per Hour (km/h)';
                          case WindSpeedUnit.mph: return 'Miles per Hour (mph)';
                          case WindSpeedUnit.ms: return 'Meters per Second (m/s)';
                        }
                      },
                      selectedLabelBuilder: (u) {
                        switch (u) {
                          case WindSpeedUnit.kmh: return 'km/h';
                          case WindSpeedUnit.mph: return 'mph';
                          case WindSpeedUnit.ms: return 'm/s';
                        }
                      },
                      onChanged: (val) {
                        if (val != null) {
                          settingsVM.setWindSpeedUnit(val);
                          weatherVM.loadAllWeatherData(forceRefresh: false);
                        }
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    
                    // Pressure Unit Choice
                    _buildDropdownRow<PressureUnit>(
                      icon: Icons.speed_rounded,
                      title: 'Pressure Unit',
                      value: settingsVM.pressureUnit,
                      items: PressureUnit.values,
                      labelBuilder: (u) => u == PressureUnit.hpa ? 'Hectopascals (hPa)' : 'Inches of Mercury (inHg)',
                      selectedLabelBuilder: (u) => u == PressureUnit.hpa ? 'hPa' : 'inHg',
                      onChanged: (val) {
                        if (val != null) {
                          settingsVM.setPressureUnit(val);
                          weatherVM.loadAllWeatherData(forceRefresh: false);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Notifications & Sync'),
              const SizedBox(height: 10),
              
              GlassContainer(
                borderRadius: 20,
                bgOpacity: 0.05,
                borderOpacity: 0.08,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_rounded, color: Colors.white70),
                      title: const Text('Severe Storm Alerts', style: TextStyle(color: Colors.white, fontSize: 15)),
                      subtitle: const Text('Get push warnings for changing climates', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      value: settingsVM.notificationsEnabled,
                      activeColor: Colors.amber,
                      onChanged: (val) => settingsVM.toggleNotifications(val),
                    ),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    SwitchListTile(
                      secondary: const Icon(Icons.refresh_rounded, color: Colors.white70),
                      title: const Text('Background Updates', style: TextStyle(color: Colors.white, fontSize: 15)),
                      subtitle: const Text('Keep weather details fresh in background', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      value: settingsVM.autoRefresh,
                      activeColor: Colors.amber,
                      onChanged: (val) => settingsVM.toggleAutoRefresh(val),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('AI Services'),
              const SizedBox(height: 10),
              
              GlassContainer(
                borderRadius: 20,
                bgOpacity: 0.05,
                borderOpacity: 0.08,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.psychology_rounded, color: Colors.purpleAccent),
                      title: const Text('AI Weather Coach', style: TextStyle(color: Colors.white, fontSize: 15)),
                      subtitle: Text(
                        settingsVM.geminiApiKey.isEmpty
                            ? 'Not Configured (Rules-Engine active)'
                            : 'Configured (Generative AI active)',
                        style: TextStyle(
                          color: settingsVM.geminiApiKey.isEmpty ? Colors.white30 : Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.edit_rounded, color: Colors.white54, size: 20),
                      onTap: () {
                        _showGeminiKeyDialog(context, settingsVM);
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Data Management'),
              const SizedBox(height: 10),
              
              GlassContainer(
                borderRadius: 20,
                bgOpacity: 0.05,
                borderOpacity: 0.08,
                padding: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                  title: const Text('Clear Saved Offline Cache', style: TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: const Text('Frees space and forces new API retrievals', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 16),
                  onTap: () async {
                    await settingsVM.clearAllCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offline database cache cleared successfully!')),
                      );
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Credits
              const Center(
                child: Column(
                  children: [
                    Text(
                      'WEATHER X',
                      style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Version 1.0.0 • Powered by OpenWeather',
                      style: TextStyle(color: Colors.white24, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required IconData icon,
    required String title,
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required String Function(T) selectedLabelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<T>(
            value: value,
            dropdownColor: Colors.grey.shade900,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((T item) {
                return Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    selectedLabelBuilder(item),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList();
            },
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showGeminiKeyDialog(BuildContext context, SettingsViewModel settingsVM) {
    final controller = TextEditingController(text: settingsVM.geminiApiKey);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Configure Gemini API Key', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a Gemini API key to enable live generative descriptions from the AI Coach. If empty, the app will use its premium rules-based advisory engine.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter API Key...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await settingsVM.setGeminiApiKey(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
