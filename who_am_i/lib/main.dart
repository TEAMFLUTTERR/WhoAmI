import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/deck_creation_screen.dart';

void main() async {
  runApp(const WhoAmIApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('decks');
}

class WhoAmIApp extends StatelessWidget {
  const WhoAmIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Who Am I',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
