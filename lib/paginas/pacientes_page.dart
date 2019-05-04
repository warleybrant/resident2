import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/main.dart';
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
      body: corpo(),
      floatingActionButton: btnAddPaciente(),
    );
  }

  Widget corpo() {
    return listaPacientes();
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
    var foto = paciente.urlFoto != null
        ? CachedNetworkImageProvider(paciente.urlFoto, errorListener: () {})
        : null;
    return foto;
  }

  Widget cardPaciente(Paciente paciente) {
    var foto = getFoto(paciente);

    Widget fotoGrupo = foto != null
        ? Container(
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: foto,
              ),
            ),
          )
        : SizedBox(
            width: 80,
            child: CircleAvatar(
              child: Icon(Icons.add_a_photo),
            ),
          );
    Widget textoGrupo = Expanded(
      child: MaterialButton(
          child: Text(paciente.nome),
          onPressed: () {
            Paciente.mostrado = paciente;
            Navigator.pushNamed(context, Paginas.PACIENTE);
          }),
    );
    Widget configuracoesGrupo = RaisedButton(
      shape: CircleBorder(),
      color: Colors.white,
      child: Icon(Icons.build),
      onPressed: () {
        Paciente.mostrado = paciente;
        Navigator.pushNamed(context, Paginas.PACIENTE_CONFIG);
      },
    );
    List<Widget> lista = [fotoGrupo, textoGrupo, configuracoesGrupo];
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
