import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/constants/constants.dart';

class RealFeelVoteWidget extends StatefulWidget {
  final String cityName;
  final HiveStorage hiveStorage;

  const RealFeelVoteWidget({
    super.key,
    required this.cityName,
    required this.hiveStorage,
  });

  @override
  State<RealFeelVoteWidget> createState() => _RealFeelVoteWidgetState();
}

class _RealFeelVoteWidgetState extends State<RealFeelVoteWidget> {
  String? _userVote; // 'warmer', 'spot_on', 'cooler'
  bool _hasVoted = false;
  
  // Simulated stats for the current city
  int _warmerVotes = 0;
  int _spotOnVotes = 0;
  int _coolerVotes = 0;

  @override
  void initState() {
    super.initState();
    _loadVoteAndStats();
  }

  @override
  void didUpdateWidget(covariant RealFeelVoteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _loadVoteAndStats();
    }
  }

  void _loadVoteAndStats() {
    // 1. Check if user already voted for this city
    final savedVote = widget.hiveStorage.get(
      AppConstants.realFeelVotesBoxName,
      widget.cityName.toLowerCase(),
      defaultValue: null,
    ) as String?;

    // 2. Generate stable simulated stats based on city name as a seed
    final seed = widget.cityName.hashCode;
    final random = math.Random(seed);
    
    // Base votes distribution
    int w = random.nextInt(35) + 10; // 10% - 45%
    int s = random.nextInt(50) + 30; // 30% - 80%
    int c = random.nextInt(25) + 5;  // 5% - 30%

    // Total must be 100%
    final sum = w + s + c;
    _warmerVotes = ((w / sum) * 100).round();
    _spotOnVotes = ((s / sum) * 100).round();
    _coolerVotes = 100 - _warmerVotes - _spotOnVotes;

    if (savedVote != null) {
      _userVote = savedVote;
      _hasVoted = true;
      // Adjust stats to include user vote if not already there
      _adjustStatsWithUserVote(savedVote);
    } else {
      _userVote = null;
      _hasVoted = false;
    }
  }

  void _adjustStatsWithUserVote(String vote) {
    if (vote == 'warmer') {
      _warmerVotes += 2;
      _spotOnVotes = math.max(0, _spotOnVotes - 1);
      _coolerVotes = math.max(0, _coolerVotes - 1);
    } else if (vote == 'cooler') {
      _coolerVotes += 2;
      _spotOnVotes = math.max(0, _spotOnVotes - 1);
      _warmerVotes = math.max(0, _warmerVotes - 1);
    } else {
      _spotOnVotes += 2;
      _warmerVotes = math.max(0, _warmerVotes - 1);
      _coolerVotes = math.max(0, _coolerVotes - 1);
    }
    // Normalize to 100%
    final sum = _warmerVotes + _spotOnVotes + _coolerVotes;
    if (sum > 0) {
      _warmerVotes = ((_warmerVotes / sum) * 100).round();
      _spotOnVotes = ((_spotOnVotes / sum) * 100).round();
      _coolerVotes = 100 - _warmerVotes - _spotOnVotes;
    }
  }

  Future<void> _submitVote(String vote) async {
    setState(() {
      _userVote = vote;
      _hasVoted = true;
      _adjustStatsWithUserVote(vote);
    });
    // Save to Hive
    await widget.hiveStorage.save(
      AppConstants.realFeelVotesBoxName,
      widget.cityName.toLowerCase(),
      vote,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24.0,
      bgOpacity: 0.05,
      borderOpacity: 0.08,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thumbs_up_down_rounded, color: Colors.amberAccent, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'How does it feel in ${widget.cityName}?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          if (!_hasVoted) ...[
            const Text(
              'Help calibrate the local weather indices. Select how the ambient thermal conditions feel right now:',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVoteButton('Warmer', 'warmer', Colors.orangeAccent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVoteButton('Spot On', 'spot_on', Colors.greenAccent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVoteButton('Cooler', 'cooler', Colors.lightBlueAccent),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'RealFeel calibration reports in this region:',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _buildStatBar('Warmer', _warmerVotes, Colors.orangeAccent, _userVote == 'warmer'),
            const SizedBox(height: 10),
            _buildStatBar('Spot On', _spotOnVotes, Colors.greenAccent, _userVote == 'spot_on'),
            const SizedBox(height: 10),
            _buildStatBar('Cooler', _coolerVotes, Colors.lightBlueAccent, _userVote == 'cooler'),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'You reported: ${_userVote == 'warmer' ? 'Warmer' : _userVote == 'cooler' ? 'Cooler' : 'Spot On'}',
                style: const TextStyle(color: Colors.white30, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoteButton(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _submitVote(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int percentage, Color color, bool isUserChoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isUserChoice ? color : Colors.white70,
                    fontSize: 12,
                    fontWeight: isUserChoice ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isUserChoice) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle_rounded, color: color, size: 12),
                ],
              ],
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                color: isUserChoice ? color : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 600),
              widthFactor: percentage / 100.0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.6), color],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
