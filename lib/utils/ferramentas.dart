import 'package:intl/intl.dart';

class Ferramentas {
  static DateTime millisecondsParaData(int dataInt) {
    if (dataInt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(dataInt);
  }

  static formatarData(DateTime horaCriacao) {
    if (horaCriacao == null) return '';
    DateFormat('HH:mm').format(horaCriacao);
  }
}
