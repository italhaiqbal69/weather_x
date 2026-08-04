class AstronomyEntity {
  final int sunrise;
  final int sunset;
  final int moonrise;
  final int moonset;
  final double moonPhase; // 0 to 1

  const AstronomyEntity({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
  });

  Map<String, dynamic> toJson() {
    return {
      'sunrise': sunrise,
      'sunset': sunset,
      'moonrise': moonrise,
      'moonset': moonset,
      'moonPhase': moonPhase,
    };
  }

  factory AstronomyEntity.fromJson(Map<String, dynamic> json) {
    return AstronomyEntity(
      sunrise: json['sunrise'] as int? ?? 0,
      sunset: json['sunset'] as int? ?? 0,
      moonrise: json['moonrise'] as int? ?? 0,
      moonset: json['moonset'] as int? ?? 0,
      moonPhase: (json['moonPhase'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Get description of moon phase
  String get moonPhaseDescription {
    if (moonPhase == 0 || moonPhase == 1) return 'New Moon';
    if (moonPhase > 0 && moonPhase < 0.25) return 'Waxing Crescent';
    if (moonPhase == 0.25) return 'First Quarter Moon';
    if (moonPhase > 0.25 && moonPhase < 0.5) return 'Waxing Gibbous';
    if (moonPhase == 0.5) return 'Full Moon';
    if (moonPhase > 0.5 && moonPhase < 0.75) return 'Waning Gibbous';
    if (moonPhase == 0.75) return 'Third Quarter Moon';
    return 'Waning Crescent';
  }

  // Golden hour is roughly 1 hour before sunset and 1 hour after sunrise
  String get goldenHourMorning => _formatTime(sunrise - 1800, sunrise + 1800);
  String get goldenHourEvening => _formatTime(sunset - 1800, sunset + 1800);

  // Blue hour is roughly 30 minutes before sunrise and 30 minutes after sunset
  String get blueHourMorning => _formatTime(sunrise - 3600, sunrise - 1800);
  String get blueHourEvening => _formatTime(sunset + 1800, sunset + 3600);

  String _formatTime(int startSec, int endSec) {
    final start = DateTime.fromMillisecondsSinceEpoch(startSec * 1000);
    final end = DateTime.fromMillisecondsSinceEpoch(endSec * 1000);
    
    String formatHour(DateTime dt) {
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $amPm';
    }
    
    return '${formatHour(start)} - ${formatHour(end)}';
  }
}
