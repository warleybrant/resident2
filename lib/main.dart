import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/cores.dart';

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
        primaryColor: Color(Cores.APPBAR),
        accentColor: Color(Cores.FLOATING_BUTTON_BACKGROUND),
        iconTheme: base.iconTheme.copyWith(color: Color(0xFFE7ECEF)),
        buttonTheme: base.buttonTheme.copyWith(
          buttonColor: Colors.yellow,
        ),

        scaffoldBackgroundColor: /*Color(Cores.CARD_BACKGROUND)*/ Colors.teal,
//        cardColor: Color(Cores.CARD_BACKGROUND),
      ),
      home: HomePage(),
    );
  }
}
