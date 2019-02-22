import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/anexo.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/nucleo.dart';

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
  List<Mensagem> mensagens = [];
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

  void manterMensagens() {
    Firestore.instance
        .collection('mensagens')
        .where('paciente', isEqualTo: id)
        .snapshots()
        .listen((snap) {
      snap.documents.forEach((documento) {
        Mensagem mensagem = Mensagem.buscaPorId(documento.documentID);
        if (mensagem == null)
          criaMensagem(documento);
        else
          alteraMensagem(documento, mensagem);
      });
      mensagens = Mensagem.porPaciente(this);

      Nucleo.atualizaTela();
    });
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

  void criaMensagem(DocumentSnapshot documento) {
    Mensagem.lista.add(Mensagem(
        id: documento.documentID,
        autor: Usuario.buscaPorId(documento.data['autor']),
        anexo: Anexo.buscaPorId(
          documento.data['anexo'],
        ),
        horaCriacao:
            Ferramentas.millisecondsParaData(documento.data['horaCriacao']),
        paciente: Paciente.buscaPorId(documento.data['paciente']),
        texto: documento.data['texto'],
        tipo: documento.data['tipo']));
  }

  void alteraMensagem(DocumentSnapshot documento, Mensagem mensagem) {
    mensagem.autor = documento.data['autor'];
    mensagem.anexo = Anexo.buscaPorId(
      documento.data['anexo'],
    );
    mensagem.horaCriacao =
        DateTime.fromMillisecondsSinceEpoch(documento.data['horaCriacao']);
    mensagem.paciente = Paciente.buscaPorId(documento.data['paciente']);
    mensagem.texto = documento.data['texto'];
    mensagem.tipo = documento.data['tipo'];
  }
}
