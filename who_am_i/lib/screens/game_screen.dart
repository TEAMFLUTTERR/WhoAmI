import 'package:flutter/material.dart';
import '../utils/sensor_helper.dart';
import '../utils/timer_helper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String currentImage = 'assets/image1.jpg'; // Beispielbild
  String currentPlayer = 'Spieler 1';
  int timeLeft = 10;

  void onCorrectGuess() {
    setState(() {
      // Logik für korrektes Raten
      currentImage = 'assets/image2.jpg'; // Neues Bild laden
    });
  }

  void onIncorrectGuess() {
    TimerHelper.startTimer(10, () {
      setState(() {
        // Nächster Spieler
        currentPlayer = 'Spieler 2';
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SensorHelper.detectTilt(onCorrectGuess, onIncorrectGuess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel läuft'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Spieler: $currentPlayer', style: const TextStyle(fontSize: 24)),
          Image.asset(currentImage, width: 300, height: 300),
          Text('Zeit: $timeLeft Sekunden',
              style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
