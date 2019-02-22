import 'package:flutter/material.dart';
import 'package:resident/componentes/bubble.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/tela.dart';

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
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Container(
          height: Tela.y(context, 90),
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
        Positioned(
          bottom: 0,
          left: Tela.x(context, 2.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Material(
                color: Colors.white,
                shape: StadiumBorder(),
                child: Container(
                  width: Tela.x(context, 85),
                  height: Tela.y(context, 5),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flexible(
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Digite aqui'),
                          ),
                        ),
                        IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.attach_file),
                          onPressed: () {},
                        ),
                        IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {},
              )
            ],
          ),
        )
      ],
    );
  }
}
