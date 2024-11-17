import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeechHomePage(),
    );
  }
}

class SpeechHomePage extends StatefulWidget {
  @override
  _SpeechHomePageState createState() => _SpeechHomePageState();
}

class _SpeechHomePageState extends State<SpeechHomePage> {
  late stt.SpeechToText _speech; // Deklaration mit 'late'
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialisierung
    _initSpeechState();
  }

  void _initSpeechState() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {});
    }
  }

  void _startListening() {
    _isListening = true;
    _speech.listen(onResult: (result) {
      setState(() {
        _recognizedText = result.recognizedWords;
        if (_recognizedText.toLowerCase() == 'hello') {
          print("Das Wort 'Bojan' wurde erkannt!");
        }
      });
    });
  }

  void _stopListening() {
    _isListening = false;
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isListening
                  ? 'Listening...'
                  : 'Press the button to start listening',
            ),
            SizedBox(height: 20),
            Text(
              'Recognized Text: $_recognizedText',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
