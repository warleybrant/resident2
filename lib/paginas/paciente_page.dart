import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resident/componentes/bubble.dart';
import 'package:resident/entidades/audio.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/download_upload.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/tela.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';

class PacientePage extends StatefulWidget {
  PacientePage();

  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  PacientePageEstado estado = PacientePageEstado.PARADO;
  TextEditingController barraTexto = TextEditingController(text: '');
  StreamSubscription streamGravacao;
  FlutterSound flutterSound = new FlutterSound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Paciente.mostrado.nome),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Paciente.mostrado = null;
              HomePage.mudarPagina(Paginas.PACIENTES);
            }),
      ),
      endDrawer: getDrawer(),
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
          child: mensagensWidget(),
        ),
        Positioned(
          bottom: Tela.y(context, 1),
          left: Tela.x(context, 2.5),
          child: barraEscrita(),
        )
      ],
    );
  }

  Widget mensagensWidget() {
    return ListView(
      shrinkWrap: true,
      children: listaMensagensBubble(),
    );
  }

  List<Widget> listaMensagensBubble() {
    List<Bubble> bubbles = [];
    Paciente.mostrado.getMensagens().forEach((mensagem) {
      String hora = Ferramentas.formatarData(mensagem.horaCriacao);
      bubbles.add(Bubble(
        isMe: mensagem.autor.id == Usuario.logado.id,
        message: mensagem.texto,
        delivered: true,
        time: hora,
      ));
    });
    return bubbles;
  }

  Widget getDrawer() {
    return Drawer(
      child: ListView(
        children: listaDrawer(),
      ),
    );
  }

  List<Widget> listaDrawer() {
    return [
      getOpcaoDrawer(
          texto: 'Hipótese Diagnóstica',
          iconeInicio: FontAwesomeIcons.edit,
          vaiPara: Paginas.HD),
      getOpcaoDrawer(
        texto: 'História de Doença Atual',
        iconeInicio: FontAwesomeIcons.stethoscope,
        vaiPara: Paginas.HDA,
      ),
      getOpcaoDrawer(
          texto: 'História Pregressa',
          iconeInicio: FontAwesomeIcons.scroll,
          vaiPara: Paginas.HP),
      getOpcaoDrawer(
          texto: 'Medicamentos',
          iconeInicio: FontAwesomeIcons.pills,
          vaiPara: Paginas.MEDICAMENTOS),
      getOpcaoDrawer(
          texto: 'Exames',
          iconeInicio: Icons.assignment,
          vaiPara: Paginas.EXAMES),
      // getOpcaoDrawer(texto: 'Alta do paciente', iconeInicio: Icons.accessibility),
    ];
  }

  Widget getOpcaoDrawer(
      {String texto, IconData iconeInicio, IconData iconeFim, int vaiPara}) {
    return ListTile(
      title: Text(texto),
      leading: Icon(iconeInicio),
      trailing: Icon(iconeFim),
      onTap: () {
        Navigator.of(context).pop();
        HomePage.mudarPagina(vaiPara);
      },
    );
  }

  Widget barraEscrita() {
    var lista = [corpoBarra()];
    if (estado == PacientePageEstado.PARADO) {
      lista.add(SizedBox(
        width: Tela.x(context, 2),
      ));
      lista.add(botaoGravarAudio());
    } else if (estado == PacientePageEstado.ESCREVENDO) {
      lista.add(SizedBox(
        width: Tela.x(context, 2),
      ));
      lista.add(botaoEnviarMensagem());
    } else if (estado == PacientePageEstado.GRAVANDO_AUDIO) {
      lista.add(botaoGravarAudio());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: lista,
    );
  }

  Widget corpoBarra() {
    double largura = estado == PacientePageEstado.GRAVANDO_AUDIO ? 75 : 85;
    return Material(
      color: Colors.white,
      shape: StadiumBorder(),
      child: Container(
        width: Tela.x(context, largura),
        height: Tela.y(context, 5),
        child: Padding(
          padding: EdgeInsets.only(left: 15),
          child: corpoBarraInterno(),
        ),
      ),
    );
  }

  Widget corpoBarraInterno() {
    List<Widget> componentes = [];
    if (estado == PacientePageEstado.PARADO) {
      componentes.add(input());
      componentes.add(botaoAnexar());
      componentes.add(botaoTirarFoto());
    } else if (estado == PacientePageEstado.ESCREVENDO ||
        estado == PacientePageEstado.GRAVANDO_AUDIO) {
      componentes.add(input());
      componentes.add(botaoTirarFoto());
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: componentes,
    );
  }

  Widget input() {
    return Flexible(
      child: TextField(
        controller: barraTexto,
        onChanged: (_) {
          setState(() {
            estado = _.isEmpty
                ? PacientePageEstado.PARADO
                : PacientePageEstado.ESCREVENDO;
          });
        },
        decoration:
            InputDecoration(border: InputBorder.none, hintText: 'Digite aqui'),
      ),
    );
  }

  Widget botaoEnviarMensagem() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.arrow_forward),
      onPressed: () {
        Mensagem mensagem = Mensagem(
          texto: barraTexto.text,
          paciente: Paciente.mostrado,
        );

        setState(() {
          mensagem.salvar();
          barraTexto.text = '';
          estado = PacientePageEstado.PARADO;
        });
      },
    );
  }

  Widget botaoAnexar() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.attach_file),
      onPressed: () {},
    );
  }

  Widget botaoTirarFoto() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.camera_alt),
      onPressed: () {},
    );
  }

  Widget botaoGravarAudio() {
    Widget botao;
    if (estado == PacientePageEstado.GRAVANDO_AUDIO) {
      botao = Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                estado = PacientePageEstado.PARADO;
                finalizarGravacao(true);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                estado = PacientePageEstado.PARADO;
                finalizarGravacao(false);
              });
            },
          )
        ],
      );
    } else {
      botao = IconButton(
        icon: Icon(Icons.mic),
        onPressed: () {
          setState(() {
            estado = PacientePageEstado.GRAVANDO_AUDIO;
            iniciarGravacao();
          });
        },
      );
    }

    return botao;
  }

  void finalizarGravacao(bool cancelado) {
    flutterSound.stopRecorder();
    if (streamGravacao != null) {
      streamGravacao.cancel();
      streamGravacao = null;

      if (!cancelado) {
        Audio audio = Audio.criar(Paciente.mostrado);
        DownloadUpload.upload(Paciente.mostrado.id, 'gravacao', 'mp4',
            nomeNoBucket: audio.id);
      }
    }
  }

  Future iniciarGravacao() async {
    var tempDir = await getTemporaryDirectory();
    String p = '${tempDir.path}/gravacao.mp4';
    String path = await flutterSound.startRecorder(p);
    print('salvo em ' + path);
    streamGravacao = flutterSound.onRecorderStateChanged.listen((_) {});
  }
}

enum PacientePageEstado {
  PARADO,
  ESCREVENDO,
  GRAVANDO_AUDIO,
}
