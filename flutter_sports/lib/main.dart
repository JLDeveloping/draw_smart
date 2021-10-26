import 'package:flutter/material.dart';
import 'package:flutter_sports/layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter zeichnet',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Layout(),
    );
  }
}