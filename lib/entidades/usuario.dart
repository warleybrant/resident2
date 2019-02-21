import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  static List<Usuario> lista = [];
  String id;
  String nome;
  String idResidente;
  String telefone;
  String uid;
  String urlFoto;
  List<dynamic> contatos;

  static Usuario logado;

  Usuario({
    this.id,
    this.nome,
    this.idResidente,
    this.telefone,
    this.uid,
    this.urlFoto,
    this.contatos,
  });

  static Usuario buscaPorId(String id) {
    if (lista == null || lista.length == 0) return null;
    return lista.firstWhere((usuario) => usuario.id == id, orElse: () => null);
  }

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  Future<Null> _criar() {
    var documento = Firestore.instance.collection('usuarios').document();
    setData(documento);
  }

  Future<Null> _alterar() {
    var documento = Firestore.instance.collection('usuarios').document(id);
    setData(documento);
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'nome': nome,
      'uid': uid,
      'telefone': telefone,
      'urlFoto': urlFoto,
      'idResidente': idResidente,
      'contatos': contatos,
    });
  }

  List<Usuario> usuariosContatos() {
    List<Usuario> conts = [];
    contatos.forEach((contato) {
      conts.add(Usuario.buscaPorId(contato));
    });
    return conts;
  }

  static List<dynamic> todosIds() {
    List<dynamic> ids = [];
    lista.forEach((usuario) {
      ids.add(usuario.id);
    });
    return ids;
  }
}
