import 'package:flutter/material.dart';

class Tela {
  static double x(BuildContext context, double percentual) {
    return MediaQuery.of(context).size.width * percentual / 100;
  }

  static double y(BuildContext context, double percentual) {
    return MediaQuery.of(context).size.height * percentual / 100;
  }

  static double abs(BuildContext context, double valor) {
    return MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height *
        valor;
  }
}
