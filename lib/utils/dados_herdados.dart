import 'package:flutter/material.dart';

class DadosHerdar extends InheritedWidget {
  final PageController paginador;

  DadosHerdar({this.paginador, Widget child});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
