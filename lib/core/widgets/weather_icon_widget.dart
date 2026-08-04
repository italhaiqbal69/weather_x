import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WeatherIconWidget extends StatelessWidget {
  final String condition;
  final String iconCode;
  final double size;

  const WeatherIconWidget({
    super.key,
    required this.condition,
    required this.iconCode,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final lowerCond = condition.toLowerCase();
    
    // Choose icon based on OpenWeather standard icon codes or names
    if (lowerCond.contains('thunderstorm') || iconCode.startsWith('11')) {
      return _buildThunderstormIcon();
    } else if (lowerCond.contains('drizzle') || lowerCond.contains('rain') || iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return _buildRainyIcon();
    } else if (lowerCond.contains('snow') || iconCode.startsWith('13')) {
      return _buildSnowyIcon();
    } else if (lowerCond.contains('fog') || lowerCond.contains('mist') || lowerCond.contains('haze') || iconCode.startsWith('50')) {
      return _buildFoggyIcon();
    } else if (lowerCond.contains('cloud') || iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return _buildCloudyIcon(iconCode.endsWith('n'));
    } else {
      return _buildSunnyIcon(iconCode.endsWith('n'));
    }
  }

  Widget _buildSunnyIcon(bool isNight) {
    if (isNight) {
      return Icon(
        Icons.nights_stay_rounded,
        color: const Color(0xFFF1C40F),
        size: size,
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds)
          .rotate(begin: -0.05, end: 0.05, duration: 3.seconds);
    }
    return Icon(
      Icons.wb_sunny_rounded,
      color: const Color(0xFFF39C12),
      size: size,
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(begin: 0.0, end: 1.0, duration: 12.seconds)
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildCloudyIcon(bool isNight) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: size * 0.1,
            top: size * 0.1,
            child: Icon(
              isNight ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
              color: isNight ? const Color(0xFFF1C40F) : const Color(0xFFF39C12),
              size: size * 0.6,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 3.seconds),
          ),
          Positioned(
            right: size * 0.05,
            bottom: size * 0.05,
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.white70,
              size: size * 0.7,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .slide(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0), duration: 4.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildRainyIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.cloud_rounded,
            color: Colors.blueGrey.shade300,
            size: size * 0.8,
          ),
          Positioned(
            bottom: size * 0.05,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    Icons.opacity_rounded,
                    color: Colors.blue.shade300,
                    size: size * 0.25,
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .slide(begin: const Offset(0, -0.5), end: const Offset(0, 0.5), duration: (800 + index * 200).ms)
                      .fadeIn(duration: 200.ms)
                      .fadeOut(delay: (600 + index * 100).ms, duration: 200.ms),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThunderstormIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.cloud_rounded,
            color: Colors.blueGrey.shade600,
            size: size * 0.8,
          ),
          Positioned(
            bottom: -size * 0.05,
            child: Icon(
              Icons.bolt_rounded,
              color: const Color(0xFFF1C40F),
              size: size * 0.6,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 500.ms)
                .shake(hz: 8, duration: 500.ms)
                .fadeIn(duration: 100.ms)
                .fadeOut(delay: 400.ms, duration: 100.ms),
          )
        ],
      ),
    );
  }

  Widget _buildSnowyIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.cloud_rounded,
            color: Colors.lightBlue.shade50,
            size: size * 0.8,
          ),
          Positioned(
            bottom: size * 0.05,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Icon(
                  Icons.ac_unit_rounded,
                  color: Colors.white,
                  size: size * 0.22,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .slide(begin: const Offset(0, -0.6), end: const Offset(0, 0.6), duration: (1200 + index * 300).ms)
                    .rotate(begin: 0, end: 1, duration: 2.seconds)
                    .fadeIn(duration: 300.ms)
                    .fadeOut(delay: 900.ms, duration: 300.ms);
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFoggyIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.cloud_rounded,
            color: Colors.grey.shade400,
            size: size * 0.7,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .slide(begin: const Offset(0, -0.05), end: const Offset(0, 0.05), duration: 3.seconds),
          Positioned(
            bottom: size * 0.1,
            child: Container(
              width: size * 0.8,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(2),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .slide(begin: const Offset(-0.1, 0), end: const Offset(0.1, 0), duration: 2500.ms),
          ),
          Positioned(
            bottom: size * 0.2,
            child: Container(
              width: size * 0.6,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(2),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .slide(begin: const Offset(0.1, 0), end: const Offset(-0.1, 0), duration: 2.seconds),
          )
        ],
      ),
    );
  }
}
