import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/recurso_midia.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/ferramentas.dart';

class Mensagem {
  static Map<String, List<Mensagem>> listagem = Map();
  String id;
  String texto;
  String identificador;
  DateTime horaCriacao;
  Grupo grupo;
  Paciente paciente;
  RecursoMidia recursoMidia;
  String tipo;
  Usuario autor;

  @override
  String toString() {
    return 'texto: $texto, tipo: $tipo';
  }

  Mensagem(
      {this.id,
      this.texto,
      this.horaCriacao,
      this.grupo,
      this.paciente,
      this.tipo,
      this.autor,
      this.recursoMidia}) {
    if (horaCriacao == null) horaCriacao = DateTime.now();
    if (autor == null) autor = Usuario.logado;
    if (tipo == null) tipo = TipoMensagem.TEXTO;
  }

  static List<Mensagem> getTodasAsMensagens() {
    var lista = <Mensagem>[];
    listagem.forEach((chave, valor) {
      lista.addAll(valor);
    });
    return lista;
  }

  static Mensagem buscaPorId(String documentID) {
    return getTodasAsMensagens().firstWhere(
        (mensagem) => mensagem.id == documentID,
        orElse: () => null);
  }

  static Mensagem deSnap(documento) {
    return Mensagem(
        id: documento.documentID,
        autor: Usuario.buscaPorId(documento.data['autor']),
        recursoMidia: RecursoMidia.buscaPorId(
          documento.data['recursoMidia'],
        ),
        horaCriacao:
            Ferramentas.millisecondsParaData(documento.data['horaCriacao']),
        paciente: Paciente.buscaPorId(documento.data['paciente']),
        texto: documento.data['texto'],
        tipo: documento.data['tipo']);
  }

  static List<Mensagem> porPaciente(Paciente paciente) {
    List<Mensagem> msgs = [];
    msgs.addAll(listagem[paciente.id]);
    msgs.sort((m1, m2) => m1.horaCriacao.millisecondsSinceEpoch
        .compareTo(m2.horaCriacao.millisecondsSinceEpoch));
    return msgs;
  }

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  void _criar() {
    var documento = Firestore.instance.collection('mensagens').document();
    id = documento.documentID;
    setData(documento);
  }

  void _alterar() {
    var documento = Firestore.instance.collection('mensagens').document(id);
    setData(documento);
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'texto': texto,
      'tipo': tipo,
      'autor': autor.id,
      'horaCriacao': Ferramentas.dataParaMillisseconds(horaCriacao),
      'recursoMidia': recursoMidia != null ? recursoMidia.id : null,
      'grupo': grupo.id,
      'paciente': paciente.id
    });
  }

  void deletar() {
    Firestore.instance.collection('mensagens').document(id).delete();
  }

  String horaFormatada() {
    return DateFormat('HH:mm').format(this.horaCriacao);
  }
}

abstract class TipoMensagem {
  static const String TEXTO = 'TEXTO';
  static const String AUDIO = 'AUDIO';
  static const String IMAGEM = 'IMAGEM';
  static const String LINK = 'LINK';
}
