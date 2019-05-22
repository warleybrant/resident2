import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resident/entidades/grupo.dart';

import 'package:resident/entidades/paciente.dart';
import 'package:http/http.dart' as http;
import 'package:resident/utils/proxy_storage.dart';

class RecursoMidia {
  static List<RecursoMidia> lista = [];
  String id;
  TipoRecurso tipo;
  String extensao;
  Grupo grupo;
  Paciente paciente;

  RecursoMidia({this.id, this.grupo, this.paciente, this.tipo, this.extensao});

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  void _criar() {
    var documento = Firestore.instance.collection('recursos_midia').document();
    this.id = documento.documentID;
    lista.add(this);
    setData(documento);
  }

  void _alterar() {
    var documento =
        Firestore.instance.collection('recursos_midia').document(id);
    setData(documento);
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'tipo': tipo.index,
      'extensao': extensao,
      'grupo': grupo.id,
      'paciente': paciente.id,
    });
  }

  void carregar(Function(File) aoCarregar, Function(dynamic) seFalhou) async {
    getCaminhoLocal().then((_) {
      File f = new File(_);
      if (!f.existsSync()) {
        download((_) {
          aoCarregar(_);
        }, seFalhou);
      } else {
        aoCarregar(f);
      }
    });
  }

  Future<String> getCaminhoLocal() async {
    Directory tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/${getNomeCompleto()}';
  }

  String getNomeCompleto() {
    String nCompleto = '${paciente.id}/${getNome()}';
    return nCompleto;
  }

  String getNome() {
    String n = '$id.$extensao';
    return n;
  }

  void download(Function(File) aoBaixar, Function(dynamic) seFalhou) async {
    final String caminhoLocal = await getCaminhoLocal();
    final File arquivo = new File('$caminhoLocal');
    if (arquivo.existsSync()) {
      aoBaixar(arquivo);
      return;
    }
    // arquivo.createSync();
    var ref = FirebaseStorage.instance
        .ref()
        .child('recursos_midia')
        .child('grupos')
        .child(grupo.id)
        .child('pacientes')
        .child(paciente.id)
        .child(tipo == TipoRecurso.AUDIO ? 'audios' : 'imagens')
        .child('$id.$extensao');
    ref.getDownloadURL().catchError((_) {
      print(_);
    }).then((url) {
      http.get(url).catchError((erro) {
        print(erro);
        seFalhou(erro);
      }).then((_) {
        if (_ != null) {
          arquivo.createSync(recursive: true);
          arquivo.writeAsBytesSync(_.bodyBytes);
          aoBaixar(arquivo);
        }
      });
    });
  }

  static RecursoMidia buscaPorId(String id) {
    return lista.firstWhere((recurso) => recurso.id == id, orElse: () => null);
  }

  static RecursoMidia deSnap(DocumentSnapshot documento) {
    return RecursoMidia(
        id: documento.documentID,
        tipo: TipoRecurso.values[documento.data['tipo']],
        grupo: Grupo.buscaPorId(documento.data['grupo']),
        paciente: Paciente.buscaPorId(documento.data['paciente']),
        extensao: documento.data['extensao']);
  }

  void upload(File arquivo,
      {Function(String) aoSubir, Function(double) progresso}) {
    ProxyStorage.uploadArquivo(arquivo, getCaminhoNoServidor(),
        aoSubir: aoSubir, progresso: progresso);
  }

  String getCaminhoNoServidor() {
    return 'recursos_midia/grupos/${grupo.id}/pacientes/${paciente.id}/${getColecao()}/$id.$extensao';
  }

  String getColecao() {
    return tipo == TipoRecurso.AUDIO ? 'audios' : 'imagens';
  }
}

enum TipoRecurso { AUDIO, IMAGEM }
