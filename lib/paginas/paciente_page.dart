import 'package:flutter/material.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/paginas/home_page.dart';

class PacientePage extends StatefulWidget {
  final PageController pagina;

  PacientePage(this.pagina);

  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Paciente.mostrado.nome),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Paciente.mostrado = null;
              widget.pagina.jumpToPage(Paginas.PACIENTES);
            }),
      ),
    );
  }
}
