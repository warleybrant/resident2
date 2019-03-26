import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/anexo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/ferramentas.dart';

class Mensagem {
  static List<Mensagem> lista = [];
  String id;
  String texto;
  Anexo anexo;
  DateTime horaCriacao;
  Paciente paciente;
  String tipo;
  Usuario autor;

  Mensagem(
      {this.id,
      this.texto,
      this.anexo,
      this.horaCriacao,
      this.paciente,
      this.tipo,
      this.autor}) {
    if (horaCriacao == null) horaCriacao = DateTime.now();
    if (autor == null) autor = Usuario.logado;
    if (tipo == null) tipo = TipoMensagem.TEXTO;
  }

  static Mensagem buscaPorId(String documentID) {
    return lista.firstWhere((mensagem) => mensagem.id == documentID,
        orElse: () => null);
  }

  static List<Mensagem> porPaciente(Paciente paciente) {
    List<Mensagem> msgs = [];
    lista.forEach((mensagem) {
      if (mensagem.paciente.id == paciente.id) msgs.add(mensagem);
    });
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
    lista.add(this);
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
      'anexo': anexo != null ? anexo.id : null,
      'paciente': paciente.id
    });
  }

  void deletar() {
    lista.remove(this);
    Firestore.instance.collection('mensagens').document(id).delete();
  }
}

abstract class TipoMensagem {
  static const String TEXTO = 'TEXTO';
  static const String AUDIO = 'AUDIO';
  static const String IMAGEM = 'IMAGEM';
  static const String LINK = 'LINK';
}
