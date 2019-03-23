import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/tela.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PacienteConfigPage extends StatefulWidget {
  PacienteConfigPage();
  @override
  _PacienteConfigPageState createState() => _PacienteConfigPageState();
}

class _PacienteConfigPageState extends State<PacienteConfigPage> {
  PacienteConfigEstado estado = PacienteConfigEstado.CRIACAO;

  TextEditingController nomeController = TextEditingController(text: '');
  MaskedTextController entradaController =
      MaskedTextController(text: '', mask: '00/00/2000');

  @override
  Widget build(BuildContext context) {
    if (Paciente.mostrado == null) Paciente.mostrado = Paciente();
    return Scaffold(
      appBar: getAppBar(),
      body: getCorpo(),
      floatingActionButton: btnSalvar(),
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
    String titulo = 'Novo Paciente';
    if (Paciente.mostrado.id != null && Paciente.mostrado.id.isEmpty) {
      titulo = Paciente.mostrado.nome;
    }
    return Text(
      titulo,
      style: getEstiloTitulo(),
    );
  }

  TextStyle getEstiloTitulo() {
    return TextStyle();
  }

  Widget getCorpo() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 5), vertical: Tela.y(context, 5)),
      child: Form(
        child: ListView(
          children: getListaCampos(),
        ),
      ),
    );
  }

  List<Widget> getListaCampos() {
    return [
      getCampoNome(),
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoEntrada()
    ];
  }

  Widget getCampoNome() {
    return TextFormField(
      controller: nomeController,
      decoration: getDecoracaoCampo(label: 'Nome:'),
    );
  }

  Widget getCampoEntrada() {
    return TextFormField(
      controller: entradaController,
      decoration: getDecoracaoCampo(label: 'Dt. Entrada:'),
    );
  }

  TextStyle getEstiloCampo() {
    return TextStyle();
  }

  InputDecoration getDecoracaoCampo({String label}) {
    return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
        fillColor: Colors.white,
        filled: true);
  }

  Widget btnSalvar() {
    return FloatingActionButton(
      child: Icon(Icons.done_outline),
      onPressed: () {
        Paciente.mostrado.nome = nomeController.text;
        Paciente.mostrado.entrada =
            Ferramentas.stringParaData(entradaController.text);
        Paciente.mostrado.grupo = Grupo.mostrado;
        Paciente.mostrado.mensagens = [];
        // Paciente.mostrado.urlFoto
        Paciente.mostrado.salvar();
        voltar();
      },
    );
  }

  void voltar() {
    Paciente.mostrado = null;
    HomePage.mudarPagina(Paginas.PACIENTES);
  }
}

enum PacienteConfigEstado { CRIACAO, ALTERACAO }
