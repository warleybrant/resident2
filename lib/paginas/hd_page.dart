import 'package:flutter/material.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';

class HDPage extends StatefulWidget {
  @override
  _HDPageState createState() => _HDPageState();
}

class _HDPageState extends State<HDPage> {
  TextEditingController hdController = TextEditingController(text: '');

  @override
  void initState() {
    hdController.text = Paciente.mostrado.hdString();
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
    return Text('Hipótese Diagnóstica');
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
    return [getCampoHipoteseDiagnostica()];
  }

  Widget getCampoHipoteseDiagnostica() {
    return TextFormField(
      controller: hdController,
      style: getEstiloCampo(),
      maxLengthEnforced: true,
      maxLines: 5,
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
    Paciente.mostrado.hd = [];
    Paciente.mostrado.hd.add(hdController.text);
    Paciente.mostrado.salvar();
  }

  voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTE);
  }
}
