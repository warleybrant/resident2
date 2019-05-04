import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Usuario {
  static List<Usuario> lista = [];
  String id;
  String nome;
  String idResidente;
  String telefone;
  String email;
  String uid;
  String urlFoto;
  List<dynamic> contatos;

  static Usuario logado;

  Usuario({
    this.id,
    this.nome = '',
    this.idResidente = '',
    this.telefone = '',
    this.email = '',
    this.uid,
    this.urlFoto,
    this.contatos,
  });

  static Usuario buscaPorId(String id) {
    if (lista == null || lista.length == 0) return null;
    return lista.firstWhere((usuario) {
      return usuario.id == id;
    }, orElse: () => null);
  }

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  void _criar() {
    var documento = Firestore.instance.collection('usuarios').document();
    setData(documento);
  }

  void _alterar() {
    var documento = Firestore.instance.collection('usuarios').document(id);
    setData(documento);
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'nome': nome,
      'uid': uid,
      'telefone': telefone,
      'email': email,
      'urlFoto': urlFoto,
      'idResidente': idResidente,
      'contatos': contatos,
    });
  }

  List<Usuario> usuariosContatos() {
    List<Usuario> conts = [];
    contatos.forEach((contato) {
      conts.add(Usuario.buscaPorId(contato.trim()));
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

  String getIdentificacao() {
    return nome == null || nome.isEmpty ? telefone : nome;
  }

  static Usuario buscaPorTelefone(String fone) {
    String tel = Ferramentas.soNumeros(fone);
    return lista.firstWhere(
        (Usuario teste) => teste.telefone != null && tel != null
            ? Ferramentas.soNumeros(teste.telefone).compareTo(tel) == 0
            : false,
        orElse: () => null);
  }

  void addContato(Usuario contatoEncontrado) {
    if (!contatos.contains(contatoEncontrado)) {
      List<dynamic> novaLista = [];
      novaLista.addAll(contatos);
      novaLista.add(contatoEncontrado.id);
      contatos = novaLista;
    }
  }

  void removerContato(Usuario contato) {
    List<dynamic> novaLista = [];
    novaLista.addAll(contatos);
    novaLista.remove(contato.id);
    contatos = novaLista;
  }

  static void deslogar() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('usuarioLogado', null);
    });
  }

  bool camposPreenchidos() {
    return nome != null &&
        nome.isNotEmpty &&
        email != null &&
        email.isNotEmpty &&
        telefone != null &&
        telefone.isNotEmpty;
  }

  static Usuario deSnap(DocumentSnapshot documento) {
    return Usuario(
        id: documento.documentID,
        nome: documento.data['nome'],
        idResidente: documento.data['idResidente'],
        telefone: documento.data['telefone'],
        email: documento.data['email'],
        uid: documento.data['uid'],
        urlFoto: documento.data['urlFoto'],
        contatos: documento.data['contatos']);
  }
}
