import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Ferramentas {
  static DateTime millisecondsParaData(int dataInt) {
    if (dataInt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(dataInt);
  }

  static formatarData(DateTime horaCriacao, {String formato}) {
    if (horaCriacao == null) return '';
    if (formato == null) formato = 'HH:mm';
    return DateFormat(formato).format(horaCriacao);
  }

  static int dataParaMillisseconds(DateTime data) {
    if (data == null) return -1;
    return data.millisecondsSinceEpoch;
  }

  static String soNumeros(String str) {
    return str.replaceAll(new RegExp(r'[^\d]'), '');
  }

  static DateTime stringParaData(String text) {
    try {
      return DateFormat('dd/MM/yyyy').parse(text);
    } catch (e) {
      return null;
    }
  }

  static Widget barreiraModal(Function aoTocar) {
    return InkWell(
      onTap: aoTocar,
      child: Opacity(
        opacity: 0.7,
        child: Container(
          color: Colors.black,
        ),
      ),
    );
  }

  static Widget loading({@required aoTocar}) {
    return Opacity(
      opacity: 0.7,
      child: InkWell(
        onTap: () {
          aoTocar();
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: Card(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
