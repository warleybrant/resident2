import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:resident/componentes/exibe_imagem.dart';
import 'package:resident/componentes/photocard.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/cores.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_firestore.dart';
import 'package:resident/utils/tela.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GruposPage extends StatefulWidget {
  GruposPage();

  @override
  _GruposPageState createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  int atualizacoes = 0;
  List<Grupo> grupos = [];
  String urlFotoMostrando;
  // File _arquivoFotoMostrando;
  Uint8List _bytesFotoMostrar;

  @override
  void initState() {
    grupos = Grupo.lista;
    ProxyFirestore.observar(Paginas.GRUPOS, () {
      if (mounted) {
        setState(() {
          grupos = Grupo.lista;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    ProxyFirestore.pararDeObservar(Paginas.GRUPOS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Text('Grupos'),
      ),
      body: getCorpo(),
      drawer: Drawer(
        child: Column(
          children: drawerItens(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(Cores.FLOATING_BUTTON_BACKGROUND),
          foregroundColor: Color(Cores.FLOATING_BUTTON_FOREGROUND),
          elevation: 8,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            criarGrupo();
          }),
    );
  }

  void criarGrupo() {
    Grupo.mostrado = Grupo();
    Navigator.pushNamed(context, Paginas.GRUPO_CONFIG);
  }

  List<Widget> drawerItens() {
    TextStyle estilo = TextStyle(fontSize: 15);
    return [
      getDrawerHeader(),
      ListTile(
        title: Text(
          'Contatos',
          style: estilo,
        ),
        leading: Icon(Icons.group),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, Paginas.CONTATOS);
        },
      ),
      Expanded(
        child: Container(),
      ),
      ListTile(
        title: Text('Sair'),
        leading: Icon(Icons.clear),
        onTap: () {
          Usuario.deslogar();
          Navigator.pushNamedAndRemoveUntil(
              context, Paginas.LOGIN, (r) => false);
        },
      )
    ];
  }

  getCorpo() {
    var _lista = <Widget>[listaGrupos()];

    if (_bytesFotoMostrar != null) {
      _lista.add(Opacity(
        opacity: 0.4,
        child: Container(
          color: Colors.black,
        ),
      ));
      _lista.add(ExibeImagem(
        bytes: _bytesFotoMostrar,
        aoTocar: () {
          setState(() {
            _bytesFotoMostrar = null;
          });
        },
      ));
    }

    return Stack(
      children: _lista,
    );
  }

  Widget listaGrupos() {
    if (grupos == null) return Container();
    List<Widget> gruposCard = [];
    grupos.forEach((grupo) {
      gruposCard.add(cardGrupo(grupo));
    });
    return ListView(
      children: gruposCard,
    );
  }

  void deslogar() {
    SharedPreferences.getInstance().then((_) {
      setState(() {
        _.remove('usuarioLogado');
      });
    });
  }

  Widget cardGrupo(Grupo grupo) {
    var fotoGrupo = InkWell(
      child: PhotoCard(
        url: grupo.getUrlFoto(),
        largura: 80,
        altura: 80,
        aoExibir: (bytes) {
          if (mounted) {
            setState(() {
              _bytesFotoMostrar = bytes;
            });
          }
        },
      ),
      onTap: () {
        setState(() {
          _bytesFotoMostrar = null;
          urlFotoMostrando = grupo.getUrlFoto();
        });
      },
    );
    Widget textoGrupo = Expanded(
      child: MaterialButton(
          child: Text(grupo.nome),
          onPressed: () {
            Grupo.mostrado = grupo;
            Navigator.pushNamed(context, Paginas.PACIENTES);
          }),
    );
    Widget configuracoesGrupo = RaisedButton(
      shape: CircleBorder(),
      color: Color(0xFF3d5f52),
      child: Icon(
        Icons.build,
        color: Colors.teal[50],
      ),
      onPressed: () {
        Grupo.mostrado = grupo;
        Navigator.pushNamed(context, Paginas.GRUPO_CONFIG);
      },
    );
    List<Widget> lista = [fotoGrupo, textoGrupo, configuracoesGrupo];
    return Card(
      key: Key(grupo.id),
      elevation: 5,
      child: Container(
        height: 80,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: lista,
          ),
        ),
      ),
    );
  }

  Widget getDrawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(Usuario.logado.getIdentificacao()),
      currentAccountPicture: PhotoCard(
        url: Usuario.logado.getUrlFoto(),
        largura: Tela.x(context, 10),
        altura: Tela.y(context, 10),
        aoExibir: (bytes) {
          setState(() {
            _bytesFotoMostrar = bytes;
          });
          Navigator.pop(context);
        },
      ),
      accountEmail: Text(Usuario.logado.email),
      onDetailsPressed: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, Paginas.PERFIL);
      },
    );
  }
}
