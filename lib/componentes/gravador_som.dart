import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class Gravador extends StatefulWidget {
  final Function(File) aposGravar;
  Gravador({this.aposGravar});
  @override
  _GravadorState createState() => _GravadorState();
}

class _GravadorState extends State<Gravador> {
  FlutterSound gravador = FlutterSound();
  StreamSubscription stream;
  EstadoGravador estado = EstadoGravador.PARADO;
  File arquivo;
  String caminhoArquivo = 'gravacao.mp3';
  String nomeArquivo;
  Directory appDocDir;
  Directory tempDir;

  @override
  Widget build(BuildContext context) {
    return getWidget();
  }

  Widget getWidget() {
    if (tempDir == null) {
      carregaCaminhosArquivo();
      return CircularProgressIndicator();
    }

    IconData icone;
    Function evento;

    switch (estado) {
      case EstadoGravador.PARADO:
        icone = Icons.mic;
        evento = iniciarGravacao;
        break;
      case EstadoGravador.GRAVANDO:
        icone = Icons.arrow_forward;
        evento = terminarGravacao;
        break;
      case EstadoGravador.PAUSADO:
        break;
      default:
    }

    return IconButton(
        icon: Icon(
          icone,
          color: Colors.black,
        ),
        onPressed: evento);
  }

  void iniciarGravacao() {
    setState(() {
      estado = EstadoGravador.GRAVANDO;
    });

    gravador.startRecorder(null).then((_) {
      nomeArquivo = _.replaceAll("file://", "");
      print(nomeArquivo);
      stream = gravador.onRecorderStateChanged.listen((e) {
        // print(e.currentPosition);
      });
    });
  }

  void terminarGravacao() {
    gravador.stopRecorder();
    if (stream != null) {
      stream.cancel();
      stream = null;
    }
    setState(() {
      estado = EstadoGravador.PARADO;
      arquivo = new File(nomeArquivo);
    });
    if (arquivo.existsSync()) widget.aposGravar(arquivo);
  }

  void carregaCaminhosArquivo() async {
    var dir = await getTemporaryDirectory();
    setState(() {
      tempDir = dir;
    });
  }
}

enum EstadoGravador { PARADO, GRAVANDO, PAUSADO }
