import 'dart:io';

class Anexo {
  static List<Anexo> lista = [];
  String id;
  String identificacao;
  String urlDownload;
  File arquivo;

  static buscaPorId(String documentID) {
    return lista.firstWhere((anexo) => anexo.id == documentID,
        orElse: () => null);
  }
}
