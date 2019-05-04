import 'package:flutter/material.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/main.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';

class HPPage extends StatefulWidget {
  @override
  _HPPageState createState() => _HPPageState();
}

class _HPPageState extends State<HPPage> {
  TextEditingController hpController = TextEditingController(text: '');

  @override
  void initState() {
    hpController.text = Paciente.mostrado.hpString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getCorpo(),
      floatingActionButton: getBotaoSalvar(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      title: getTitulo(),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          voltar();
        },
      ),
    );
  }

  Widget getTitulo() {
    return Text('História Pregressa');
  }

  Widget getCorpo() {
    return Form(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 5), vertical: Tela.y(context, 5)),
        child: ListView(children: getListaCampos()),
      ),
    );
  }

  Widget getBotaoSalvar() {
    return FloatingActionButton(
      child: Icon(Icons.done),
      onPressed: () {
        salvar();
        voltar();
      },
    );
  }

  List<Widget> getListaCampos() {
    return [getHistoriaPregressa()];
  }

  Widget getHistoriaPregressa() {
    return TextFormField(
      controller: hpController,
      maxLines: 5,
      maxLengthEnforced: true,
      style: getEstiloCampo(),
      decoration: getDecoracaoCampo(label: ''),
    );
  }

  TextStyle getEstiloCampo() {
    return TextStyle();
  }

  InputDecoration getDecoracaoCampo({String label}) {
    return InputDecoration(
      border: OutlineInputBorder(),
      labelText: label,
      filled: true,
      fillColor: Colors.white,
    );
  }

  void salvar() {
    Paciente.mostrado.hp = [];
    Paciente.mostrado.hp.add(hpController.text);
    Paciente.mostrado.salvar();
  }

  voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTE);
  }
}
