import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:who_am_i/utils/string_similiarity.dart';
import '../utils/sensor_helper.dart';
import '../utils/timer_helper.dart';
import 'dart:async';
import 'leaderboard_screen.dart';
import 'package:who_am_i/model/player.dart';

class GameScreen extends StatefulWidget {
  final List<Map<String, String>> deckImages;
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
  late List<Map<String, String>> _deck;
  int _currentPlayerIndex = 0;
  late int _totalTime;
  bool _isGameOver = false;
  bool _isListening = false;

  late stt.SpeechToText _speech;
  String _lastWords = '';
  double _confidenceThreshold = 0.7;

  Timer? _playerSwitchTimer;
  int _playerSwitchCountdown = 10;

  StreamSubscription? _gyroscopeSubscription;
  bool _canProcessTilt = true;
  static const _tiltCooldownDuration = Duration(milliseconds: 500);

  // UI feedback for tilt
  double _currentTilt = 0.0;
  Color _tiltColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.players);
    _deck = List.from(widget.deckImages);
    _totalTime = widget.gameTimeMinutes * 60;
    _speech = stt.SpeechToText();
    _initializeSpeech();
    _startGameTimer();
    _listenToGyroscope();
  }

  void _listenToGyroscope() {
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      if (!_canProcessTilt || _isGameOver) return;

      setState(() {
        _currentTilt = event.y;
        if (_currentTilt > 2.0) {
          _tiltColor = Colors.green;
        } else if (_currentTilt < -2.0) {
          _tiltColor = Colors.red;
        } else {
          _tiltColor = Colors.grey;
        }
      });

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
    if (_isListening) {
      _stopListening(); // Stop voice detection if active
    }

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

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) => print('Speech Error: $error'),
    );
    if (available) {
      setState(() => _isListening = false);
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening') {
      setState(() => _isListening = false);
    }
  }

  Future<void> _startListening() async {
    if (!_isListening && _canProcessTilt) {
      // Only start if not in tilt cooldown
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _checkAnswer(_lastWords);
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _checkAnswer(String spokenWords) {
    if (_deck.isEmpty) return;

    String correctName = _deck[0]['name'] ?? '';
    double similarity =
        spokenWords.toLowerCase().similarityTo(correctName.toLowerCase());

    if (similarity >= _confidenceThreshold) {
      _correctGuess();
      _stopListening();
    }
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

  void _startGameTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _totalTime > 0 && !_isGameOver) {
        setState(() {
          _totalTime--;
        });
      } else {
        timer.cancel();
        if (mounted && !_isGameOver) {
          _endGame();
        }
      }
    });
  }

  void _startPlayerSwitchTimer() {
    _playerSwitchTimer?.cancel();
    _playerSwitchCountdown = 10;

    _playerSwitchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _playerSwitchCountdown > 0) {
        setState(() {
          _canProcessTilt = false;
          _playerSwitchCountdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canProcessTilt = true;
            _nextImage();
          });
        }
      }
    });
  }

  void _endGame() {
    if (mounted) {
      setState(() {
        _isGameOver = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel läuft'),
      ),
      body: _isGameOver
          ? const Center(
              child: Text("Spiel beendet!", style: TextStyle(fontSize: 24)))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer display
                Text(
                  "Zeit: ${(_totalTime / 60).floor()}:${(_totalTime % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),

                // Tilt indicator
                Container(
                  width: double.infinity,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: _tiltColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment:
                        Alignment((_currentTilt / 5).clamp(-1.0, 1.0), 0),
                    widthFactor: 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _tiltColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Current image
                if (_deck.isNotEmpty)
                  Image.asset(
                    _deck[0]['image'] ?? '',
                    height: 200,
                    width: 200,
                  ),
                const SizedBox(height: 20),

                // Player info
                Text(
                  "Spieler: ${_players[_currentPlayerIndex].name}",
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  "Punkte: ${_players[_currentPlayerIndex].score}",
                  style: const TextStyle(fontSize: 20),
                ),

                // Player switch countdown
                if (_playerSwitchCountdown > 0)
                  Text(
                    "Nächster Spieler in $_playerSwitchCountdown Sekunden",
                    style: const TextStyle(fontSize: 16),
                  ),

                const SizedBox(height: 20),

                // Voice detection controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _canProcessTilt
                          ? (_isListening ? _stopListening : _startListening)
                          : null,
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                      label: Text(_isListening ? 'Stop' : 'Start Listening'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isListening ? Colors.red : Colors.green,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Interaction instructions
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tilt up ⬆️ for correct guess\nTilt down ⬇️ for skip\nOr use voice detection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _playerSwitchTimer?.cancel();
    _speech.cancel();
    super.dispose();
  }
}
