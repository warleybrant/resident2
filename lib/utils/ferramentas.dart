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
    return DateFormat('dd/MM/yyyy').parse(text);
  }
}
