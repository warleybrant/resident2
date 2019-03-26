import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/contatos.dart';
import 'package:resident/paginas/exames_page.dart';
import 'package:resident/paginas/grupo_page_config.dart';
import 'package:resident/paginas/grupos_page.dart';
import 'package:resident/paginas/hd_page.dart';
import 'package:resident/paginas/hda_page.dart';
import 'package:resident/paginas/hp_page.dart';
import 'package:resident/paginas/login.dart';
import 'package:resident/paginas/medicamentos_page.dart';
import 'package:resident/paginas/paciente_config.dart';
import 'package:resident/paginas/paciente_page.dart';
import 'package:resident/paginas/pacientes_page.dart';
import 'package:resident/paginas/perfil_page.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static Grupo grupoExibido;
  static Usuario usuarioLogado;

  static void mudarPagina(int pagina) {
    HomePageState.pagina.jumpToPage(pagina);
    atualizaTela();
  }

  static void atualizaTela() {
    HomePageState.instancia.atualizaTela();
  }

  @override
  HomePageState createState() => HomePageState();
}

class Paginas {
  static const int LOGIN = 0;
  static const int GRUPOS = 1;
  static const int GRUPO_CONFIG = 2;
  static const int CONTATOS = 3;
  static const int PACIENTES = 4;
  static const int PACIENTE = 5;
  static const int PACIENTE_CONFIG = 6;
  static const int PERFIL = 7;
  static const int HP = 8;
  static const int HD = 9;
  static const int HDA = 10;
  static const int EXAMES = 11;
  static const int MEDICAMENTOS = 12;
  static PageController paginador;
}

class HomePageState extends State<HomePage> {
  static PageController pagina = PageController(initialPage: Paginas.GRUPOS);
  static HomePageState instancia;
  int atualizacoes = 0;
  Estado estado = Estado.NORMAL;

  static StatefulWidget loginPage = LoginPage();
  static StatefulWidget gruposPage = GruposPage();
  static StatefulWidget grupoPage = GrupoPage();
  static StatefulWidget contatosPage = ContatosPage();
  static StatefulWidget pacientesPage = PacientesPage();
  static StatefulWidget pacientePage = PacientePage();
  static StatefulWidget pacienteConfigPage = PacienteConfigPage();
  static StatefulWidget perfilPage = PerfilPage();
  static StatefulWidget hpPage = HPPage();
  static StatefulWidget hdPage = HDPage();
  static StatefulWidget hdaPage = HDAPage();
  static StatefulWidget examesPage = ExamesPage();
  static StatefulWidget medicamentosPage = MedicamentosPage();

  @override
  void initState() {
//    Nucleo.state = this;
    instancia = this;
    pagina.addListener(() {
      loginPage = LoginPage();
      gruposPage = GruposPage();
      if (Grupo.mostrado != null) {
        grupoPage = GrupoPage();
        pacientesPage = PacientesPage();
      }

      contatosPage = ContatosPage();
      if (Paciente.mostrado != null) {
        pacientePage = PacientePage();
        pacienteConfigPage = PacienteConfigPage();
        hpPage = HPPage();
        hdPage = HDPage();
        hdaPage = HDAPage();
        examesPage = ExamesPage();
        medicamentosPage = MedicamentosPage();
      }

      perfilPage = PerfilPage();
    });
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
          /*  0  */ loginPage,
          /*  1  */ gruposPage,
          /*  2  */ grupoPage,
          /*  3  */ contatosPage,
          /*  4  */ pacientesPage,
          /*  5  */ pacientePage,
          /*  6  */ pacienteConfigPage,
          /*  7  */ perfilPage,
          /*  8  */ hpPage,
          /*  9  */ hdPage,
          /*  10 */ hdaPage,
          /*  11 */ examesPage,
          /*  12 */ medicamentosPage,
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
            if (Usuario.logado.camposPreenchidos())
              pagina = PageController(initialPage: Paginas.GRUPOS);
            else
              pagina = PageController(initialPage: Paginas.PERFIL);
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
            paciente = adicionarPaciente(documento);
          else
            alterarPaciente(documento, paciente);
          paciente.manterMensagens();
          paciente.manterMedicamentos();
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
  Paciente adicionarPaciente(DocumentSnapshot documento) {
    Paciente paciente = Paciente(
      id: documento.documentID,
      nome: documento.data['nome'],
      grupo: Grupo.buscaPorId(documento.data['grupo']),
      telefone: documento.data['telefone'],
      entrada: Ferramentas.millisecondsParaData(documento.data['entrada']),
      hp: documento.data['hp'],
      hda: documento.data['hda'],
      hd: documento.data['hd'],
      alta: documento.data['alta'],
    );
    Paciente.lista.add(paciente);
    return paciente;
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
        email: documento.data['email'],
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

enum Estado { NORMAL, CARREGANDO }
