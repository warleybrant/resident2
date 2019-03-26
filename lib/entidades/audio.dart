import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/download_upload.dart';

class Audio {
  static List<Audio> lista = [];

  String id;
  Paciente paciente;
  String url;
  File arquivoLocal;

  Audio({this.id, this.paciente, this.url, this.arquivoLocal});

  bool baixado() {
    return arquivoLocal != null;
  }

  static Audio criar(Paciente paciente) {
    String id = Firestore.instance.collection('audios').document().documentID;
    return Audio(id: id, paciente: Paciente.buscaPorId(paciente.id));
  }

  Future<Null> baixar() {
    DownloadUpload.download('audios', id).then((_) {
      this.arquivoLocal = _;
    });
    return null;
  }

  static Audio buscaPorId(String id) {
    if (lista == null || lista.length == 0) return null;
    return lista.firstWhere((audio) {
      return audio.id == id;
    }, orElse: () => null);
  }

  static List<Audio> porPaciente(Paciente paciente) {
    List<Audio> audios = [];
    lista.forEach((audio) {
      if (audio.paciente.id == paciente.id) audios.add(audio);
    });
    return audios;
  }

  void carregar() {
    if (arquivoLocal == null) {
      File f = new File(DownloadUpload.tempDirPath + '\\' + id);
      if (!f.existsSync())
        baixar();
      else
        arquivoLocal = f;
    }
  }

  void deletar() {
    Firestore.instance.collection('audios').document(id).delete();
    lista.remove(this);
  }
}
