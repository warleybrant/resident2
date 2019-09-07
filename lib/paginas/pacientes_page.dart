// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:resident/componentes/exibe_imagem.dart';
import 'package:resident/componentes/photocard.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_firestore.dart';

class PacientesPage extends StatefulWidget {
  PacientesPage();

  @override
  _PacientesPageState createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  int atualizacoes = 0;
  List<Paciente> pacientes = [];
  String urlFotoMostrando;
  Uint8List _bytesFotoMostrar;

  @override
  void initState() {
    pacientes = Paciente.porGrupo(Grupo.mostrado.id);
    ProxyFirestore.observar(Paginas.PACIENTES, () {
      if (mounted) {
        setState(() {
          pacientes = Paciente.porGrupo(Grupo.mostrado.id);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    ProxyFirestore.pararDeObservar(Paginas.PACIENTES);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Grupo.mostrado.nome}'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Grupo.mostrado = null;
              Navigator.popUntil(
                  context, (r) => r.settings.name == Paginas.GRUPOS);
            }),
      ),
      body: getCorpo(),
      floatingActionButton: btnAddPaciente(),
    );
  }

  Widget getCorpo() {
    var _lista = <Widget>[listaPacientes()];

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

    return Stack(children: _lista);
  }

  Widget listaPacientes() {
    if (pacientes == null) return Container();
    List<Widget> pacientesCard = [];
    pacientes.forEach((paciente) {
      pacientesCard.add(cardPaciente(paciente));
    });
    return ListView(
      children: pacientesCard,
    );
  }

  dynamic getFoto(Paciente paciente) {
    var foto = paciente.getUrlFoto() != null
        ? NetworkImage(paciente.getUrlFoto())
        // ? CachedNetworkImageProvider(paciente.getUrlFoto(),
        //     errorListener: () {})
        : null;
    return foto;
  }

  Widget cardPaciente(Paciente paciente) {
    var fotoPaciente = InkWell(
      child: PhotoCard(
        url: paciente.getUrlFoto(),
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
          urlFotoMostrando = paciente.getUrlFoto();
        });
      },
    );

    Widget textoPaciente = Expanded(
      child: MaterialButton(
          child: Text(paciente.nome),
          onPressed: () {
            Paciente.mostrado = paciente;
            Navigator.pushNamed(context, Paginas.PACIENTE);
          }),
    );
    Widget configuracoesPaciente = RaisedButton(
      shape: CircleBorder(),
      color: Color(0xFF3d5f52),
      child: Icon(
        Icons.build,
        color: Colors.teal[50],
      ),
      onPressed: () {
        Paciente.mostrado = paciente;
        Navigator.pushNamed(context, Paginas.PACIENTE_CONFIG);
      },
    );
    List<Widget> lista = [fotoPaciente, textoPaciente, configuracoesPaciente];
    return Card(
      key: Key(paciente.id),
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

  Widget btnAddPaciente() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        criarPaciente();
      },
    );
  }

  void criarPaciente() {
    Paciente.mostrado = Paciente();
    Navigator.pushNamed(context, Paginas.PACIENTE_CONFIG);
  }
}
