import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/paginas/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();
    Firestore.instance.settings(persistenceEnabled: true);
    return MaterialApp(
      title: 'Residente',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        buttonColor: Colors.yellow,
        iconTheme: base.iconTheme.copyWith(color: Color(0xFFE7ECEF)),
        scaffoldBackgroundColor: /*Color(Cores.CARD_BACKGROUND)*/ Colors.teal,
//        cardColor: Color(Cores.CARD_BACKGROUND)
      ),
      home: HomePage(),
    );
  }
}
