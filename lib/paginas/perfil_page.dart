import 'package:flutter/material.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/tela.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  var nomeController = TextEditingController(text: '');
  var emailController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getTitulo(),
      body: getCorpo(),
    );
  }

  Widget getTitulo() {
    return AppBar(
        title: Text('Perfil'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              HomePage.mudarPagina(Paginas.GRUPOS);
            }));
  }

  Widget getCorpo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Tela.x(context, 5)),
      child: ListView(
        children: listaCampos(),
      ),
    );
  }

  List<Widget> listaCampos() {
    return [
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoNome(),
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoEmail()
    ];
  }

  Widget getCampoNome() {
    return TextFormField(
      controller: nomeController,
      decoration: getCampoDecoration(label: 'Nome:', icone: Icons.account_circle),
      style: getCampoStyle(),
    );
  }

  Widget getCampoEmail() {
    return TextFormField(
      controller: emailController,
      decoration: getCampoDecoration(label: 'Email:', icone: Icons.email),
      style: getCampoStyle(),
    );
  }

  TextStyle getCampoStyle() {
    return TextStyle();
  }

  InputDecoration getCampoDecoration({String label, IconData icone}) {
    return InputDecoration(
      labelText: label,
      fillColor: Colors.lightBlueAccent,
      icon: Icon(icone),
      border: OutlineInputBorder()
    );
  }
}
