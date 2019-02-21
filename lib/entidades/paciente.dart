import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/grupo.dart';

class Paciente {
  static Paciente mostrado;
  static List<Paciente> lista = [];
  String id;
  String nome;
  Grupo grupo;
  DateTime entrada;
  String telefone;
  String urlFoto;
  List<String> hda = [];
  List<String> hd = [];
  List<String> hp = [];
  bool alta = false;

  Paciente({
    this.id,
    this.nome,
    this.grupo,
    this.entrada,
    this.telefone,
    this.alta,
    this.hd,
    this.hda,
    this.hp,
    this.urlFoto,
  });

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  Future<Null> _criar() {
    var documento = Firestore.instance.collection('pacientes').document();
    setData(documento);
  }

  Future<Null> _alterar() {
    var documento = Firestore.instance.collection('pacientes').document(id);
    setData(documento);
  }

  static List<Paciente> porGrupo(String grupoId) {
    List<Paciente> selecionados = [];
    lista.forEach((paciente) {
      if (paciente.grupo.id == grupoId) selecionados.add(paciente);
    });
    return selecionados;
  }

  static List<dynamic> todosIds() {
    List<dynamic> ids = [];
    lista.forEach((paciente) {
      ids.add(paciente.id);
    });
    return ids;
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'nome': nome,
      'grupo': grupo.id,
      'telefone': telefone,
      'entrada': entrada,
      'hp': hp,
      'hda': hda,
      'hd': hd,
      'urlFoto': urlFoto,
      'alta': alta,
    });
  }

  static Paciente buscaPorId(String id) {
    if (lista == null || lista.length == 0) return null;
    return lista.firstWhere((paciente) {
      return paciente.id == id;
    }, orElse: () => null);
  }
}
