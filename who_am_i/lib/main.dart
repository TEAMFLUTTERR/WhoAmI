import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WhoAmIApp());
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
