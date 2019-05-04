import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nomeController.text = Paciente.mostrado.nome;
    var data = Paciente.mostrado.entrada;
    if (data == null) data = DateTime.now();
    entradaController.text =
        Ferramentas.formatarData(data, formato: 'dd/MM/yyyy');

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
          voltar();
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
        key: _formKey,
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
      validator: (_) {
        if (_.isEmpty) return "Nome não pode ser vazio";
        if (_.length < 3) return "Nome muito curto";
      },
      decoration: getDecoracaoCampo(label: 'Nome:'),
    );
  }

  Widget getCampoEntrada() {
    return TextFormField(
      controller: entradaController,
      keyboardType: TextInputType.number,
      validator: (_) {
        if (_.isEmpty) return "Campo não pode ser vazio";
        if (Ferramentas.stringParaData(_) == null) return "Data inválida";
        int dia = int.parse(_.substring(0, 2));
        int mes = int.parse(_.substring(3, 5));
        int ano = int.parse(_.substring(6, 10));
        if (dia < 1 ||
            dia > 31 ||
            mes < 1 ||
            mes > 12 ||
            ano < 2000 ||
            ano > 3000) return "Data inválida";
      },
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
        if (_formKey.currentState.validate()) {
          Paciente.mostrado.nome = nomeController.text;
          Paciente.mostrado.entrada =
              Ferramentas.stringParaData(entradaController.text);
          Paciente.mostrado.grupo = Grupo.mostrado;
          // Paciente.mostrado.urlFoto

          Paciente.mostrado.salvar();
          voltar();
        }
      },
    );
  }

  void voltar() {
    Paciente.mostrado = null;
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTES);
  }
}

enum PacienteConfigEstado { CRIACAO, ALTERACAO }
