import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/sensor_helper.dart';
import '../utils/timer_helper.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final List<String> deckImages;
  final List<String> playerNames;
  final int gameTimeMinutes;

  const GameScreen({
    Key? key,
    required this.deckImages,
    required this.playerNames,
    required this.gameTimeMinutes,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> _players;
  late List<String> _deck;
  int _currentPlayerIndex = 0;
  int _score = 0;
  late int _totalTime;
  bool _isGameOver = false;

  Timer? _playerSwitchTimer;
  int _playerSwitchCountdown = 10;

  StreamSubscription? _gyroscopeSubscription;
  bool _canProcessTilt = true;
  static const _tiltCooldownDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.playerNames);
    _deck = List.from(widget.deckImages);
    _totalTime = widget.gameTimeMinutes * 60;
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

      const tiltThresholdSuccess = 3.0;
      const tiltThresholdFailure = -3.0;

      if (event.y > tiltThresholdSuccess) {
        _processTilt(_correctGuess);
      } else if (event.y < tiltThresholdFailure) {
        _processTilt(_nextPlayer);
      }
    });
  }

  void _processTilt(VoidCallback action) {
    setState(() {
      _canProcessTilt = false;
    });
    action();
    Future.delayed(_tiltCooldownDuration, () {
      setState(() {
        _canProcessTilt = true;
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
    });

    _startPlayerSwitchTimer();
  }

  void _nextImage() {
    if (_deck.isNotEmpty) {
      setState(() {
        _deck.removeAt(0);
      });
    } else {
      _endGame();
    }
  }

  void _startPlayerSwitchTimer() {
    _playerSwitchTimer?.cancel();
    _playerSwitchCountdown = 10;

    _playerSwitchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_playerSwitchCountdown > 0) {
        setState(() {
          _canProcessTilt = false;
          _playerSwitchCountdown--;
        });
      } else {
        timer.cancel();
        _canProcessTilt = true;
        _nextImage();
      }
    });
  }

  void _endGame() {
    setState(() {
      _isGameOver = true;
    });

    Navigator.pushReplacementNamed(
      context,
      '/leaderboard',
      arguments: {
        "scores": {"${_players[_currentPlayerIndex]}": _score},
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel läuft'),
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
