import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/contatos.dart';
import 'package:resident/paginas/grupo_page.dart';
import 'package:resident/paginas/grupos_page.dart';
import 'package:resident/paginas/login.dart';
import 'package:resident/paginas/paciente_page.dart';
import 'package:resident/paginas/pacientes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static Grupo grupoExibido;
  static Usuario usuarioLogado;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController pagina = PageController(initialPage: 2);
  int atualizacoes = 0;
  Estado estado = Estado.NORMAL;

  @override
  void initState() {
    manterUsuarios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return filtro();
  }

  Widget paginaWidget() {
    return SafeArea(
      child: PageView(
        controller: pagina,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        pageSnapping: false,
        children: <Widget>[
          LoginPage(pagina),
          GruposPage(pagina),
          GrupoPage(pagina),
          ContatosPage(pagina),
          PacientesPage(pagina),
          PacientePage(pagina)
        ],
      ),
    );
  }

  Future<String> idUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('usuarioLogado');
  }

  Widget filtro() {
    if (Usuario.logado != null) {
      return montaPagina();
    }
    return FutureBuilder(
      future: idUsuarioLogado(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.connectionState == ConnectionState.done) {
          Usuario usuario = Usuario.buscaPorId(snap.data);
          if (usuario != null) {
            Usuario.logado = usuario;
            manterGrupos();
            pagina = PageController(initialPage: Paginas.GRUPOS);
          } else
            pagina = PageController(initialPage: Paginas.LOGIN);
          return montaPagina();
        } else {
          return Container(
            color: Colors.primaries[8],
          );
        }
      },
    );
  }

  Widget loading(Widget child) {
    return Stack(
      key: GlobalKey(),
      children: <Widget>[
        child,
        Opacity(
          opacity: .8,
          child: ModalBarrier(
              key: GlobalKey(), dismissible: false, color: Colors.black),
        ),
        Center(
          child: new CircularProgressIndicator(
            strokeWidth: 5,
          ),
        )
      ],
    );
  }

  Widget montaPagina() {
    switch (estado) {
      case Estado.NORMAL:
        return paginaWidget();
      case Estado.CARREGANDO:
        return loading(paginaWidget());
      default:
        return Container();
    }
  }

  /// Mantém atualizada a lista estática dos usuários baseada nos
  /// retornos do firebase
  void manterUsuarios() {
    Firestore.instance.collection('usuarios').snapshots().listen((snap) {
      snap.documents.forEach((documento) {
        Usuario usuario = Usuario.buscaPorId(documento.documentID);
        if (usuario == null)
          adicionaUsuario(documento);
        else
          alteraUsuario(documento, usuario);
      });
      atualizaTela();
    });
  }

  /// Mantém atualizada a lista estática dos grupos baseada nos retornos
  /// do firebase
  void manterGrupos() {
    Firestore.instance
        .collection('grupos')
        .where('contatos', arrayContains: Usuario.logado.id)
        .snapshots()
        .listen((snap) {
      snap.documents.forEach((documento) {
        Grupo grupo = Grupo.buscaPorId(documento.documentID);
        if (grupo == null)
          adicionarGrupo(documento);
        else
          alterarGrupo(documento, grupo);
      });
      manterPacientes();
      atualizaTela();
    });
  }

  /// Mantém atualizada a lista estática dos pacientes baseada nos retornos
  /// do firebase
  void manterPacientes() {
    Grupo.lista.forEach((grupo) {
      Firestore.instance
          .collection('pacientes')
          .where('grupo', isEqualTo: grupo.id)
          .snapshots()
          .listen((snap) {
        snap.documents.forEach((documento) {
          Paciente paciente = Paciente.buscaPorId(documento.documentID);
          if (paciente == null)
            adicionarPaciente(documento);
          else
            alterarPaciente(documento, paciente);
        });
        atualizaTela();
      });
    });
  }

  /// Altera um grupo da lista estática de grupos baseado
  /// no retorno do firebase
  void alterarGrupo(DocumentSnapshot documento, Grupo grupo) {
    grupo.nome = documento.data['nome'];
    grupo.descricao = documento.data['descricao'];
    grupo.contatos = documento.data['contatos'];
    grupo.urlFoto = documento.data['urlFoto'];
  }

  /// Adiciona um grupo à lista estática de grupos baseado
  /// no retorno do firebase
  void adicionarGrupo(DocumentSnapshot documento) {
    Grupo.lista.add(
      Grupo(
          id: documento.documentID,
          nome: documento.data['nome'],
          descricao: documento.data['descricao'],
          contatos: documento.data['contatos'],
          urlFoto: documento.data['urlFoto']),
    );
  }

  /// Adiciona um paciente à lista estática de pacientes baseado
  /// no retorno do firebase
  void adicionarPaciente(DocumentSnapshot documento) {
    Paciente.lista.add(
      Paciente(
        id: documento.documentID,
        nome: documento.data['nome'],
        grupo: Grupo.buscaPorId(documento.data['grupo']),
        telefone: documento.data['telefone'],
        entrada: DateTime.fromMillisecondsSinceEpoch(documento.data['entrada']),
        hp: documento.data['hp'],
        hda: documento.data['hda'],
        hd: documento.data['hd'],
        alta: documento.data['alta'],
      ),
    );
  }

  /// Altera um paciente da lista estática de pacientes baseado
  /// no retorno do firebase
  void alterarPaciente(DocumentSnapshot documento, Paciente paciente) {
    paciente.nome = documento.data['nome'];
    paciente.grupo = Grupo.buscaPorId(documento.data['grupo']);
    paciente.telefone = documento.data['telefone'];
    paciente.entrada =
        DateTime.fromMillisecondsSinceEpoch(documento.data['entrada']);
    paciente.hp = documento.data['hp'];
    paciente.hda = documento.data['hda'];
    paciente.hd = documento.data['hd'];
    paciente.urlFoto = documento.data['urlFoto'];
    paciente.alta = documento.data['alta'];
  }

  /// Chamada para o setState a ser realizada a partir de atualizações do firestore
  void atualizaTela() {
    if (mounted) {
      setState(() {
        ++atualizacoes;
      });
    }
  }

  /// Adiciona um usuário à lista estática de usuários baseado
  /// no retorno do firebase
  void adicionaUsuario(DocumentSnapshot documento) {
    Usuario.lista.add(Usuario(
        id: documento.documentID,
        nome: documento.data['nome'],
        idResidente: documento.data['idResidente'],
        telefone: documento.data['telefone'],
        uid: documento.data['uid'],
        urlFoto: documento.data['urlFoto'],
        contatos: documento.data['contatos']));
  }

  /// Altera um usuário da lista estática de usuários baseado
  /// no retorno do firebase
  void alteraUsuario(DocumentSnapshot documento, Usuario usuario) {
    usuario.nome = documento.data['nome'];
    usuario.idResidente = documento.data['idResidente'];
    usuario.telefone = documento.data['telefone'];
    usuario.uid = documento.data['uid'];
    usuario.urlFoto = documento.data['urlFoto'];
    usuario.contatos = documento.data['contatos'];
  }
}

class Paginas {
  static const int LOGIN = 0;
  static const int GRUPOS = 1;
  static const int GRUPO = 2;
  static const int CONTATOS = 3;
  static const int PACIENTES = 4;
  static const int PACIENTE = 5;
  static PageController paginador;
}

enum Estado { NORMAL, CARREGANDO }
