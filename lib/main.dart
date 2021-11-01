import 'package:flutter/material.dart';
import 'package:ricky_and_morty/windows/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomeApp(),
    );
  }
}
