import 'package:intl/intl.dart';

class Ferramentas {
  static DateTime millisecondsParaData(int dataInt) {
    if (dataInt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(dataInt);
  }

  static formatarData(DateTime horaCriacao) {
    if (horaCriacao == null) return '';
    return DateFormat('HH:mm').format(horaCriacao);
  }

  static int dataParaMillisseconds(DateTime data) {
    if (data == null) return -1;
    return data.millisecondsSinceEpoch;
  }

  static String soNumeros(String str) {
    return str.replaceAll(new RegExp(r'[^\d]'), '');
  }
}
