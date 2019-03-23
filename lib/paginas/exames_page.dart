import 'package:flutter/material.dart';
import 'package:resident/paginas/home_page.dart';

class ExamesPage extends StatefulWidget {
  @override
  _ExamesPageState createState() => _ExamesPageState();
}

class _ExamesPageState extends State<ExamesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      title: getTitulo(),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          HomePage.mudarPagina(Paginas.PACIENTE);
        },
      ),
    );
  }

  Widget getTitulo() {
    return Text('Exames');
  }
}
