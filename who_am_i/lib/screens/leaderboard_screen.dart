import 'package:flutter/material.dart';
import 'package:who_am_i/model/player.dart';
import 'package:confetti/confetti.dart';

class LeaderboardScreen extends StatefulWidget {
  final List<Player> players;
  const LeaderboardScreen({Key? key, required this.players}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    // Start confetti animation when the screen is displayed
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort players by score in descending order
    widget.players.sort((a, b) => b.score.compareTo(a.score));

    // Extract the top 3 players for the podium
    final top3 = widget.players.take(3).toList();
    final remainingPlayers = widget.players.length > 3
        ? widget.players.sublist(3)
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Stack(
        children: [
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Podium for the top 3 players
                _buildPodium(top3),
                const SizedBox(height: 16),
                Expanded(
                  // Remaining players in a scrollable list
                  child: ListView.builder(
                    itemCount: remainingPlayers.length,
                    itemBuilder: (context, index) {
                      final player = remainingPlayers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text((index + 4).toString()),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: Text(
                          '${player.score} points',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Player> top3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        if (top3.length > 1)
          _buildPodiumSpot(
            position: 2,
            player: top3[1],
            height: 120,
            color: Colors.grey[400]!,
          ),
        // 1st place
        if (top3.isNotEmpty)
          _buildPodiumSpot(
            position: 1,
            player: top3[0],
            height: 150,
            color: Colors.amber,
          ),
        // 3rd place
        if (top3.length > 2)
          _buildPodiumSpot(
            position: 3,
            player: top3[2],
            height: 100,
            color: Colors.brown,
          ),
      ],
    );
  }

  Widget _buildPodiumSpot({
    required int position,
    required Player player,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Text(
            player.name[0].toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          player.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${player.score} points',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$position',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
