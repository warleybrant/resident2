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
  void initState() {
    nomeController.text = Paciente.mostrado.nome;
    entradaController.text = Ferramentas.formatarData(Paciente.mostrado.entrada,
        formato: 'dd/MM/yyyy');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      actions: getAcoes(),
    );
  }

  Widget getTitulo() {
    String titulo = 'Novo Paciente';
    if (Paciente.mostrado.nome.isNotEmpty) titulo = Paciente.mostrado.nome;
    return Text(
      titulo,
      style: getEstiloTitulo(),
    );
  }

  List<Widget> getAcoes() {
    if (Paciente.mostrado.id != null) {
      return [getBotaoAcaoExcluirPaciente()];
    }
    return [];
  }

  Widget getBotaoAcaoExcluirPaciente() {
    return FlatButton(
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () async {
        if ((await popupConfirmaExclusao())) {
          Paciente.mostrado.deletar();
          HomePage.mudarPagina(Paginas.PACIENTES);
        }
      },
    );
  }

  Future<bool> popupConfirmaExclusao() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
                'Se você confirmar, irá apagar definitivamente todos as mensagens, audios, medicamentos, exames e todo o conteúdo. Confirma?'),
            actions: <Widget>[
              getBotaoConfirmaDeletePopup(),
              getBotaoCancelaDeletePopup()
            ],
          );
        });
  }

  Widget getBotaoConfirmaDeletePopup() {
    return FlatButton(
      child: Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget getBotaoCancelaDeletePopup() {
    return FlatButton(
      child: Icon(Icons.close),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
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
      keyboardType: TextInputType.number,
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
