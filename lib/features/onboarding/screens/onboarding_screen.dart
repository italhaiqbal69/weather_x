import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/weather_background_widget.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstTime, false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _requestLocation() async {
    try {
      final granted = await sl<LocationService>().requestPermission();
      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission granted!')),
        );
        _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. You can configure it later in Settings.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _requestNotifications() async {
    final granted = await sl<NotificationService>().requestPermissions();
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications enabled!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission denied.')),
      );
    }
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherBackgroundWidget(
        themeType: WeatherThemeType.morning, // Bright morning theme for onboarding
        child: SafeArea(
          child: Column(
            children: [
              // Top Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < 2)
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildIntroPage(),
                    _buildLocationPage(),
                    _buildNotificationsPage(),
                  ],
                ),
              ),

              // Bottom Indicator and Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Smooth page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isSelected = _currentPage == index;
                        return AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: isSelected ? 24.0 : 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Primary navigation button
                    if (_currentPage == 0)
                      _buildButton(
                        'Continue',
                        () => _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut),
                      )
                    else if (_currentPage == 1)
                      _buildButton('Grant Location Access', _requestLocation)
                    else
                      _buildButton('Enable Alerts', _requestNotifications),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFF37335),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildIntroPage() {
    return _buildPageLayout(
      icon: Icons.wb_sunny_rounded,
      title: 'Precision Climate Insights',
      body: 'WeatherX delivers high-precision meteorological reports with real-time maps, micro-climate trackers, and detailed atmospheric metrics.',
      accentColor: const Color(0xFFF1C40F),
    );
  }

  Widget _buildLocationPage() {
    return _buildPageLayout(
      icon: Icons.location_on_rounded,
      title: 'Auto Local Weather',
      body: 'Allow WeatherX to retrieve your geolocation to instantly serve up weather forecasts, air quality alerts, and tile overlays for where you stand.',
      accentColor: const Color(0xFFE74C3C),
    );
  }

  Widget _buildNotificationsPage() {
    return _buildPageLayout(
      icon: Icons.notifications_active_rounded,
      title: 'Storm Warning Alerts',
      body: 'Stay protected with instant notifications for lightning storms, heavy rainfall warnings, and shifting wind flows in your area.',
      accentColor: const Color(0xFF9B59B6),
    );
  }

  Widget _buildPageLayout({
    required IconData icon,
    required String title,
    required String body,
    required Color accentColor,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Circle Icon
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Icon(icon, color: accentColor, size: 70),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 2.seconds),
            
            const SizedBox(height: 32),
  
            // Glassmorphic Info Card
            GlassContainer(
              borderRadius: 24,
              bgOpacity: 0.08,
              borderOpacity: 0.12,
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.15, end: 0.0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
