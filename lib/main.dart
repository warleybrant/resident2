import 'package:flutter/material.dart';
import 'package:resident/paginas/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();
    return MaterialApp(
      title: 'Residente',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        iconTheme: base.iconTheme.copyWith(color: Colors.white),
        scaffoldBackgroundColor: Colors.primaries[8],
        buttonColor: Colors.greenAccent,
      ),
      home: HomePage(),
    );
  }
}
