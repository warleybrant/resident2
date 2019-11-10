import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/audio.dart';
import 'package:resident/entidades/exame.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/medicamento.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/utils/ferramentas.dart';

class Paciente {
  static Paciente mostrado;
  static Map<String, List<Paciente>> listagem = Map();
  String id;
  String nome = '';
  Grupo grupo;
  DateTime entrada;
  String telefone = '';
  String urlFoto = '';
  List hda = [];
  List hd = [];
  List hp = [];
  List<Mensagem> _mensagens = [];
  List<Medicamento> _medicamentos = [];
  List<Exame> _exames = [];
  List<Audio> _audios = [];
  List usuariosNotificar;
  bool alta = false;

  Paciente({
    this.id,
    this.nome = '',
    this.grupo,
    this.entrada,
    this.telefone = '',
    this.alta = false,
    this.hd,
    this.hda,
    this.hp,
    this.urlFoto,
    this.usuariosNotificar,
  }) {
    if (usuariosNotificar == null) {
      usuariosNotificar = [];
      grupo.contatos.forEach((contato) {
        usuariosNotificar.add(contato);
      });
    }
  }

  static List<Paciente> getTodosOsPacientes() {
    var lista = <Paciente>[];
    listagem.forEach((chave, valor) {
      lista.addAll(valor);
    });
    return lista;
  }

  getUrlFoto() {
    if (urlFoto == null) return 'padroes/paciente_padrao.png';
    return 'fotos_capa/pacientes/$id.png';
  }

  List<Mensagem> getMensagens() {
    _mensagens = Mensagem.porPaciente(this);
    return _mensagens;
  }

  List<Medicamento> getMedicamentos() {
    _medicamentos = Medicamento.porPaciente(this);
    return _medicamentos;
  }

  List<Audio> getAudios() {
    _audios = Audio.porPaciente(this);
    return _audios;
  }

  getExames() {
    _exames = Exame.porPaciente(this);
    return _exames;
  }

  void salvar(
      {Uint8List bytesFoto,
      Function aoSalvarFotoNoServidor,
      Function(double) progresso}) {
    if (id == null) {
      _criar();
      return;
    } else {
      _alterar();
    }

    if (bytesFoto != null) {
      Ferramentas.salvarArquivoAsync('fotos_capa/pacientes/$id.png',
          aoUpload: (ref, url, f) {
        this.urlFoto = url;
        this.salvar();
        aoSalvarFotoNoServidor();
      }, bytes: bytesFoto, percentual: progresso);
      // ProxyStorage.uploadArquivo(
      //   fotoParaUpload,
      //   'fotos_capa/pacientes/$id.png',
      //   progresso: progresso,
      //   aoSubir: (r) {
      //     var ref = FirebaseStorage.instance
      //         .ref()
      //         .child('fotos_capa/pacientes/$id.png');
      //     ref.getDownloadURL().then((_) {
      //       this.urlFoto = _;
      //       this.salvar();
      //       aoSalvarFotoNoServidor();
      //     });
      //   },
      // );
    }
  }

  void _criar() {
    var documento = Firestore.instance.collection('pacientes').document();
    this.id = documento.documentID;
    listagem[grupo.id].add(this);
    setData(documento);
  }

  void _alterar() {
    var documento = Firestore.instance.collection('pacientes').document(id);
    setData(documento);
  }

  static List<Paciente> porGrupo(String grupoId) {
    List<Paciente> selecionados = [];
    listagem[grupoId].forEach((paciente) {
      if (paciente.grupo.id == grupoId) selecionados.add(paciente);
    });
    return selecionados;
  }

  static List<dynamic> todosIds() {
    List<dynamic> ids = [];
    getTodosOsPacientes().forEach((paciente) {
      ids.add(paciente.id);
    });
    return ids;
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'nome': nome,
      'grupo': grupo.id,
      'telefone': telefone,
      'entrada': Ferramentas.dataParaMillisseconds(entrada),
      'hp': hp,
      'hda': hda,
      'hd': hd,
      'urlFoto': urlFoto,
      'alta': alta,
      'usuariosNotificar': usuariosNotificar,
    });
  }

  static Paciente buscaPorId(String id) {
    if (getTodosOsPacientes() == null || getTodosOsPacientes().length == 0)
      return null;
    return getTodosOsPacientes().firstWhere((paciente) {
      return paciente.id == id;
    }, orElse: () => null);
  }

  String hpString() {
    if (hp == null || hp.length == 0) return '';
    String hpStr = '';
    hp.forEach((str) {
      hpStr += str + '\n';
    });
    return hpStr;
  }

  String hdaString() {
    if (hda == null || hda.length == 0) return '';
    String hdaStr = '';
    hda.forEach((str) {
      hdaStr += str + '\n';
    });
    return hdaStr;
  }

  String hdString() {
    if (hd == null || hd.length == 0) return '';
    String hdStr = '';
    hd.forEach((str) {
      hdStr += str + '\n';
    });
    return hdStr;
  }

  void notificar(String usuarioId) {
    List _usersNot = List.from(usuariosNotificar);
    if (!_usersNot.contains(usuarioId)) {
      _usersNot.add(usuarioId);
    }
    usuariosNotificar = _usersNot;
  }

  void naoNotificar(String usuarioId) {
    List _usersNot = List.from(usuariosNotificar);
    if (_usersNot.contains(usuarioId)) {
      _usersNot.remove(usuarioId);
    }
    usuariosNotificar = _usersNot;
  }

  void deletar() {
    getAudios().forEach((audio) {
      audio.deletar();
    });
    getMensagens().forEach((mensagem) {
      mensagem.deletar();
    });
    getMedicamentos().forEach((medicamento) {
      medicamento.deletar();
    });
    Firestore.instance.collection('pacientes').document(id).delete();
  }

  static Paciente deSnap(DocumentSnapshot documento) {
    return Paciente(
      id: documento.documentID,
      nome: documento.data['nome'],
      grupo: Grupo.buscaPorId(documento.data['grupo']),
      telefone: documento.data['telefone'],
      entrada: Ferramentas.millisecondsParaData(documento.data['entrada']),
      hp: documento.data['hp'],
      hda: documento.data['hda'],
      hd: documento.data['hd'],
      alta: documento.data['alta'],
      urlFoto: documento.data['urlFoto'],
      usuariosNotificar: documento.data['usuariosNotificar'],
    );
  }
}
