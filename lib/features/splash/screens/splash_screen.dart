import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/weather_background_widget.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../weather/presentation/viewmodels/weather_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    // 1. Preload local data caches
    final weatherVM = Provider.of<WeatherViewModel>(context, listen: false);
    await weatherVM.loadAllWeatherData(forceRefresh: false);

    // 2. Wait for short splash duration to show logo animations
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // 3. Query settings to determine first-time routing
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool(AppConstants.keyFirstTime) ?? true;

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherBackgroundWidget(
        themeType: WeatherThemeType.night, // Midnight theme style for loading
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(
                  Icons.wb_twilight_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              )
                  .animate()
                  .scale(duration: 1.seconds, curve: Curves.elasticOut)
                  .then()
                  .shake(hz: 3, duration: 1.seconds),
              
              const SizedBox(height: 24),
              
              // App Name Text
              const Text(
                'WEATHER X',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0.0),
              
              const SizedBox(height: 10),
              
              // App Tagline Text
              const Text(
                'Premium Atmospheric Forecasting',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
