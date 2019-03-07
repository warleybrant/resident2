import 'package:flutter/material.dart';
import 'package:resident/paginas/home_page.dart';

class PacienteConfigPage extends StatefulWidget {
  final PageController pagina;
  PacienteConfigPage(this.pagina);
  @override
  _PacienteConfigPageState createState() => _PacienteConfigPageState();
}

class _PacienteConfigPageState extends State<PacienteConfigPage> {
  PacienteConfigEstado estado = PacienteConfigEstado.CRIACAO;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: corpo(),
      floatingActionButton: btnSalvar(),
    );
  }

  Widget appBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          voltar();
        },
      ),
    );
  }

  Widget corpo() {
    return Container();
  }

  Widget btnSalvar() {
    return FloatingActionButton(
      onPressed: () {},
    );
  }

  void voltar() {
    widget.pagina.jumpToPage(Paginas.PACIENTES);
  }
}

enum PacienteConfigEstado { CRIACAO, ALTERACAO }
