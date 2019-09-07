import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:resident/componentes/avatar_alteravel.dart';
import 'package:resident/componentes/exibe_imagem.dart';
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
  String urlFotoMostrando;
  Uint8List _bytesFotoMostrar;

  bool carregando = false;
  bool salvandoImagem = false;
  Uint8List _bytesArquivoFoto;
  double progressoUpload = 0;

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
    return montaPagina();
  }

  Widget montaPagina() {
    if (carregando) {
      return Stack(
        children: <Widget>[
          getScaffold(),
          Opacity(
            opacity: 0.7,
            child: Container(
              color: Colors.black,
            ),
          ),
          getIndicadorProgresso()
        ],
      );
    }
    return getScaffold();
  }

  Widget getIndicadorProgresso() {
    return Center(
      child: Card(
        child: Container(
          width: Tela.x(context, 20),
          height: Tela.y(context, 10),
          child: InkWell(
            child: Center(
              child: CircularProgressIndicator(),
            ),
            onTap: () {
              setState(() {
                carregando = false;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget getScaffold() {
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
    if (Paciente.mostrado != null &&
        Paciente.mostrado.nome != null &&
        Paciente.mostrado.nome.isNotEmpty) titulo = Paciente.mostrado.nome;
    return Text(
      titulo,
      style: getEstiloTitulo(),
    );
  }

  List<Widget> getAcoes() {
    if (Paciente.mostrado != null && Paciente.mostrado.id != null) {
      return [getBotaoAcaoExcluirPaciente()];
    }
    return [];
  }

  fotoPaciente() {
    return AvatarAlteravel(
      Tela.x(context, 40),
      Tela.x(context, 40),
      Paciente.mostrado.getUrlFoto(),
      _bytesArquivoFoto,
      aoSelecionarImagem: (File arquivoSelecionado) {
        if (arquivoSelecionado != null) {
          setState(() {
            _bytesArquivoFoto = arquivoSelecionado.readAsBytesSync();
            salvandoImagem = true;
            carregando = false;
          });
        }
      },
      aoBuscarImagem: () {
        setState(() {
          carregando = true;
        });
      },
    );
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
    if (Paciente.mostrado == null) return Container();
    var _lista = <Widget>[];
    _lista.add(ListView(
      children: <Widget>[form()],
    ));

    if (_bytesFotoMostrar != null) {
      _lista.add(Opacity(
        opacity: 0.4,
        child: Container(
          color: Colors.black,
        ),
      ));
      _lista.add(ExibeImagem(
        bytes: _bytesFotoMostrar,
        aoTocar: () {
          setState(() {
            _bytesFotoMostrar = null;
          });
        },
      ));
    }

    return Stack(
      children: _lista,
    );
  }

  form() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getListaCampos(),
      ),
      key: _formKey,
    );
  }

  List<Widget> getListaCampos() {
    return [
      SizedBox(
        height: Tela.y(context, 1),
      ),
      Center(
        child: InkWell(
          child: fotoPaciente(),
          onTap: () {
            setState(() {
              if (_bytesArquivoFoto != null) {
                setState(() {
                  _bytesFotoMostrar = _bytesArquivoFoto;
                });
              } else {
                setState(() {
                  urlFotoMostrando = Grupo.mostrado.getUrlFoto();
                });
              }
            });
          },
        ),
      ),
      SizedBox(
        height: Tela.y(context, 1),
      ),
      getCampoNome(),
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoEntrada()
    ];
  }

  Widget getCampoNome() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 6), vertical: Tela.y(context, 1)),
      child: TextFormField(
        controller: nomeController,
        validator: (_) {
          if (_.isEmpty) return "Nome não pode ser vazio";
          if (_.length < 3) return "Nome muito curto";
        },
        decoration: getDecoracaoCampo(label: 'Nome:'),
      ),
    );
  }

  Widget getCampoEntrada() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Tela.x(context, 6),
        vertical: Tela.y(context, 1),
      ),
      child: TextFormField(
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
      ),
    );
    ;
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

          Paciente.mostrado.salvar(
              bytesFoto: _bytesArquivoFoto,
              progresso: (_) {
                if (mounted) {
                  setState(() {
                    progressoUpload = _;
                  });
                }
              },
              aoSalvarFotoNoServidor: () {
                if (mounted) {
                  setState(() {
                    salvandoImagem = false;
                    voltar();
                  });
                }
              });
          setState(() {
            carregando = true;
          });
          if (_bytesArquivoFoto == null) voltar();
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
