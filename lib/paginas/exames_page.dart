import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resident/entidades/exame.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/recurso_midia.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_firestore.dart';
import 'package:resident/utils/tela.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:open_file/open_file.dart';

class ExamesPage extends StatefulWidget {
  @override
  _ExamesPageState createState() => _ExamesPageState();
}

class _ExamesPageState extends State<ExamesPage> {
  Widget popupCriacao;
  List<Exame> exames = [];
  bool carregando = false;
  TextEditingController descController = TextEditingController(text: '');
  MaskedTextController horaAdmController =
      MaskedTextController(text: '00/00/0000', mask: '00/00/2000');

  @override
  void initState() {
    exames = Exame.porPaciente(Paciente.mostrado);
    ProxyFirestore.observar(Paginas.EXAMES, () {
      if (mounted) {
        var _lista = <Exame>[];
        _lista.addAll(Exame.porPaciente(Paciente.mostrado));
        setState(() {
          exames = _lista;
          print('exames atualizadas');
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getCorpo(),
      floatingActionButton: getBotaoCriar(),
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
    return Text('Exames');
  }

  Widget getCorpo() {
    List<Widget> listaWidgets = [];
    listaWidgets.add(Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 5), vertical: Tela.y(context, 1.5)),
      child: Container(
        height: Tela.y(context, 75),
        child: ListView(
          children: listaExames(),
        ),
      ),
    ));
    if (popupCriacao != null) {
      listaWidgets.add(Opacity(
        opacity: .6,
        child: InkWell(
          onTap: () {
            fechaPopupCriacao();
          },
          child: Container(
            color: Colors.black,
          ),
        ),
      ));
      listaWidgets.add(Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 10), vertical: Tela.y(context, 10)),
        child: popupCriacao,
      ));
    }
    if (carregando) {
      listaWidgets.add(Opacity(
        opacity: 0.7,
        child: InkWell(
          onTap: () {
            setState(() {
              carregando = false;
            });
          },
          child: Container(
            color: Colors.black,
            // child: ,
          ),
        ),
      ));
      listaWidgets.add(Center(
        child: Container(
          width: 50,
          height: 50,
          color: Colors.white,
          child: CircularProgressIndicator(),
        ),
      ));
    }
    return Stack(children: listaWidgets);
  }

  voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTE);
  }

  Widget getBotaoCriar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          heroTag: 'galeria',
          child: Icon(Icons.image),
          onPressed: () {
            // FilePicker.getFile(type: FileType.ANY).then((arquivo) {
            //   criarExame(arquivo);
            // });
            pegarImagem(ImageSource.gallery).then((arquivo) {
              criarExame(arquivo);
            });
          },
        ),
        SizedBox(width: Tela.x(context, 1)),
        FloatingActionButton(
          heroTag: 'camera',
          child: Icon(Icons.camera_alt),
          onPressed: () {
            pegarImagem(ImageSource.camera).then((arquivo) {
              criarExame(arquivo);
            });
          },
        ),
        SizedBox(width: Tela.x(context, 1)),
        FloatingActionButton(
          heroTag: 'add',
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              abrirPopupCriacao(null);
            });
          },
        )
      ],
    );
  }

  Future<File> pegarImagem(ImageSource fonte) async {
    return await ImagePicker.pickImage(source: fonte);
  }

  criarExame(arquivo) {
    if (arquivo != null) {
      print('###Tamnho do arquivo: ${arquivo.lengthSync()}###');
      List<String> partes = arquivo.path.split('.');
      String ultimaParte = partes.last;
      Mensagem msg;
      RecursoMidia recurso = RecursoMidia(
          tipo: TipoRecurso.IMAGEM,
          grupo: Paciente.mostrado.grupo,
          paciente: Paciente.mostrado,
          extensao: ultimaParte);
      recurso.salvar();
      // recurso.upload(
      //     aoSubir: (resultado) {
      //       msg.tipo = TipoMensagem.IMAGEM;
      //       msg.salvar();
      //       Exame exame = exameDoForm();
      //       exame.recursoId = recurso.id;
      //       exame.descricao = 'Anexo';
      //       exame.salvar();
      //       setState(() {
      //         carregando = false;
      //       });
      //     },
      //     caminhoLocal: arquivo.path,
      //     progresso: (evento, percentual) {
      //       setState(() {
      //         carregando = true;
      //       });
      //       msg.texto = '${percentual.toStringAsFixed(2)} %';
      //       print(msg.texto);
      //       msg.salvar();
      //     });
      msg = Mensagem(
          tipo: TipoMensagem.TEXTO,
          grupo: Grupo.mostrado,
          paciente: Paciente.mostrado,
          recursoMidia: recurso,
          texto: 'Enviando...');
      msg.salvar();
    }
  }

  void abrirPopupCriacao(Exame exame) {
    if (exame == null) {
      exame = Exame(paciente: Paciente.mostrado, data: DateTime.now());
    }
    Exame.mostrado = exame;
    descController.text = exame.descricao;
    horaAdmController.text =
        Ferramentas.formatarData(exame.data, formato: 'dd/MM/yyyy');
    popupCriacao = Card(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 1),
          vertical: Tela.y(context, 1),
        ),
        width: Tela.x(context, 80),
        height: Tela.y(context, 45),
        child: montaPopupCriacao(),
      ),
    );
  }

  Widget montaPopupCriacao() {
    return Column(
      children: <Widget>[
        Expanded(
          child: montaCorpoPopupCriacao(),
        ),
        montaLinhaBotoesPopupCriacao()
      ],
    );
  }

  Widget montaCorpoPopupCriacao() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 2), vertical: Tela.y(context, 1)),
        child: Container(
          child: ListView(
            children: <Widget>[
              getCampoDescricaoPopupCriacao(),
              SizedBox(height: Tela.y(context, 2)),
              getCampoHoraAdministradaPopupCriacao(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCampoDescricaoPopupCriacao() {
    return TextFormField(
      controller: descController,
      decoration: getDecoracaoCampoPopupCriacao(label: 'Descrição:'),
    );
  }

  Widget getCampoHoraAdministradaPopupCriacao() {
    return TextFormField(
      controller: horaAdmController,
      decoration: getDecoracaoCampoPopupCriacao(label: 'Dt. Administrada:'),
    );
  }

  InputDecoration getDecoracaoCampoPopupCriacao({String label}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    );
  }

  Widget montaLinhaBotoesPopupCriacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        getBotaoPopupCriacaoCancelar(),
        getBotaoPopupCriacaoSalvar(),
      ],
    );
  }

  Widget getBotaoPopupCriacaoSalvar() {
    return FlatButton(
      child: Text(
        'Salvar',
        style: getEstiloBotoesPopup(cor: Colors.blue),
      ),
      onPressed: () {
        setState(() {
          Exame.mostrado.descricao = descController.text;
          Exame.mostrado.data =
              Ferramentas.stringParaData(horaAdmController.text);
          Exame.mostrado.salvar();
          popupCriacao = null;
        });
      },
    );
  }

  Widget getBotaoPopupCriacaoCancelar() {
    return FlatButton(
      child: Text(
        'Cancelar',
        style: getEstiloBotoesPopup(cor: Colors.black),
      ),
      onPressed: () {
        fechaPopupCriacao();
      },
    );
  }

  void fechaPopupCriacao() {
    setState(() {
      popupCriacao = null;
    });
  }

  TextStyle getEstiloBotoesPopup({Color cor}) {
    return TextStyle(color: cor);
  }

  List<Widget> listaExames() {
    List<Widget> linhasExame = [];
    Paciente.mostrado.getExames().forEach((Exame exame) {
      linhasExame.add(getLinhaExame(exame));
    });
    return linhasExame;
  }

  Widget getLinhaExame(Exame exame) {
    var _lista = <Widget>[
      Expanded(
        child: Card(
          child: Container(
            color: Colors.white,
            height: Tela.y(context, 7),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: Tela.x(context, 1)),
                child: Text(
                  // 'aaa',
                  exame.descricao,
                  style: getEstiloCampo(),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
    if (exame.getRecurso() != null) {
      _lista.add(
        Card(
          child: getBotaoAbrirArquivo(exame.getRecurso()),
        ),
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          abrirPopupCriacao(exame);
        });
      },
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _lista,
        ),
      ),
    );
  }

  TextStyle getEstiloCampo() {
    return TextStyle(color: Colors.black, fontSize: 17);
  }

  Widget getBotaoAbrirArquivo(RecursoMidia recurso) {
    return IconButton(
      icon: Icon(
        Icons.image,
        color: Colors.black,
      ),
      onPressed: () {
        recurso.carregar((arquivo) {
          setState(() {
            carregando = true;
            OpenFile.open(arquivo.path).then((_) {
              setState(() {
                carregando = false;
              });
            });
          });
        }, (erro) {
          print('deu ruim');
          print(erro.toString());
        });
      },
    );
  }

  Exame exameDoForm() {
    return Exame(
      data: Ferramentas.stringParaData(horaAdmController.text),
      descricao: descController.text,
      paciente: Paciente.mostrado,
    );
  }
}
