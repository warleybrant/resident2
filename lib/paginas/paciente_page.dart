import 'package:flutter/material.dart';
import 'package:resident/componentes/bubble.dart';
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
      endDrawer: Drawer(),
      body: corpo(),
    );
  }

  Widget corpo() {
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .85,
          color: Colors.teal,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Bubble(
                isMe: false,
                message: 'O paciente deu entrada com dor na garganta',
                delivered: true,
                time: '10:20',
              ),
              Bubble(
                isMe: true,
                message:
                    'O paciente deu entrada com dor na gargantaO paciente deu entrada com dor na gargantaO paciente deu entrada com dor na garganta',
                delivered: true,
                time: '10:20',
              )
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Material(
              color: Colors.white,
              shape: StadiumBorder(),
              child: Container(
                width: MediaQuery.of(context).size.width * .8,
                height: MediaQuery.of(context).size.height * .06,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
//                    TextFormField(
//                      decoration: InputDecoration(),
//                    ),
                    IconButton(
                      color: Colors.blue,
                      icon: Icon(Icons.mic),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {},
            )
          ],
        )
      ],
    );
  }
}
