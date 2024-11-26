//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final List<String> deckImages; // Bilder aus dem ausgewählten Deck
  final List<String> playerNames; // Namen der Spieler

  const GameScreen({
    required this.deckImages,
    required this.playerNames,
    Key? key,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> _players; // Kopie der Spielernamen
  late List<String> _deck; // Kopie des Bild-Decks
  int _currentPlayerIndex = 0; // Aktueller Spieler
  int _score = 0; // Score des aktuellen Spielers
  int _totalTime = 600; // Gesamtzeit (10 Minuten)
  bool _isGameOver = false;

  // Timer für Spielerwechsel
  Timer? _playerSwitchTimer;
  int _playerSwitchCountdown = 10;

  // Gyroskop-Steuerung
  StreamSubscription? _gyroscopeSubscription;
  bool _canProcessTilt = true;
  static const _tiltCooldownDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.playerNames);
    _deck = List.from(widget.deckImages);
    _startGameTimer();
    _listenToGyroscope();
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _playerSwitchTimer?.cancel();
    super.dispose();
  }

  void _startGameTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTime > 0 && !_isGameOver) {
        setState(() {
          _totalTime--;
        });
      } else {
        timer.cancel();
        _endGame();
      }
    });
  }

  void _listenToGyroscope() {
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      if (!_canProcessTilt || _isGameOver) return;

      // Normalize values and set thresholds for tilt detection
      const tiltThresholdSuccess = 3.0; // Adjust for upward tilt
      const tiltThresholdFailure = -3.0; // Adjust for downward tilt

      // Success Tilt (upward tilt)
      if (event.y > tiltThresholdSuccess) {
        _processTilt(_correctGuess);
      }
      // Failure Tilt (downward tilt)
      else if (event.y < tiltThresholdFailure) {
        _processTilt(_nextPlayer);
      }
    });
  }

  void _processTilt(VoidCallback action) {
    setState(() {
      _canProcessTilt = false; // Disable further events temporarily
    });
    action();
    Future.delayed(_tiltCooldownDuration, () {
      setState(() {
        _canProcessTilt = true; // Re-enable tilt processing
      });
    });
  }

  void _correctGuess() {
    if (_isGameOver) return;

    setState(() {
      _score++;
      _nextImage();
    });
  }

  void _nextPlayer() {
    if (_isGameOver) return;

    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      _canProcessTilt = false; // Block tilt input during countdown
    });

    _startPlayerSwitchTimer();
  }

  void _nextImage() {
    if (_deck.isNotEmpty) {
      setState(() {
        _deck.removeAt(0); // Nächstes Bild
      });
    } else {
      _endGame(); // Keine Bilder mehr
    }
  }

  void _startPlayerSwitchTimer() {
    _playerSwitchTimer?.cancel();
    _playerSwitchCountdown = 10;

    _playerSwitchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_playerSwitchCountdown > 0) {
        setState(() {
          _playerSwitchCountdown--;
        });
      } else {
        timer.cancel();
        _canProcessTilt = true; // Re-enable tilt after countdown
        _nextImage(); // Now that the countdown is done, show the next image
      }
    });
  }

  void _endGame() {
    setState(() {
      _isGameOver = true;
    });

    Navigator.pushReplacementNamed(
      context,
      '/leaderboard', // Übergabe an Person 4
      arguments: {
        "scores": {
          "${_players[_currentPlayerIndex]}": _score
        }, // Beispiel Score
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spielphase"),
      ),
      body: _isGameOver
          ? const Center(
              child: Text(
                "Spiel beendet!",
                style: TextStyle(fontSize: 24),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Zeit: ${(_totalTime / 60).floor()}:${(_totalTime % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                if (_deck.isNotEmpty)
                  Image.asset(
                    _deck[0],
                    height: 200,
                    width: 200,
                  ),
                const SizedBox(height: 20),
                Text(
                  "Spieler: ${_players[_currentPlayerIndex]}",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Text(
                  "Punkte: $_score",
                  style: const TextStyle(fontSize: 20),
                ),
                if (_playerSwitchCountdown > 0)
                  Text(
                    "Nächster Spieler in $_playerSwitchCountdown Sekunden",
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
    );
  }
}
