import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/sensor_helper.dart';
import '../utils/timer_helper.dart';
import 'dart:async';
import 'leaderboard_screen.dart';
import 'package:who_am_i/model/player.dart';

class GameScreen extends StatefulWidget {
  final List<String> deckImages;
  final List<Player> players;
  final int gameTimeMinutes;

  const GameScreen({
    Key? key,
    required this.deckImages,
    required this.players,
    required this.gameTimeMinutes,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Player> _players;
  late List<String> _deck;
  int _currentPlayerIndex = 0;
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
    _players = List.from(widget.players);
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
      _players[_currentPlayerIndex].score++;
      _nextImage();
    });
  }

  void _nextPlayer() {
    if (_isGameOver) return;

    setState(() {
      if (_currentPlayerIndex == _players.length - 1) {
        _currentPlayerIndex = 0;
      } else {
        _currentPlayerIndex++;
      }
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          players: _players,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Wer bin ich?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: _isGameOver
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gamepad_outlined,
                    size: 100,
                    color: Colors.deepPurple[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Spiel beendet!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[400],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Zeit: ${(_totalTime / 60).floor()}:${(_totalTime % 60).toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _totalTime < 30 ? Colors.red : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_deck.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  _deck[0],
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.deepPurple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Spieler: ${_players[_currentPlayerIndex].name}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple[800],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Punkte: ${_players[_currentPlayerIndex].score}",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_playerSwitchCountdown > 0)
                    Text(
                      "Nächster Spieler in $_playerSwitchCountdown Sekunden",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}