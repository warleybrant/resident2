import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resident/entidades/recurso_midia.dart';
import 'package:resident/utils/tela.dart';
import 'package:audioplayers/audioplayers.dart';

class BalaoTocarAudio extends StatefulWidget {
  final RecursoMidia recurso;
  final bool recursoProprio;
  // final UniqueKey chaveUnica;
  BalaoTocarAudio(this.recurso, this.recursoProprio);

  @override
  _BalaoTocarAudioState createState() => _BalaoTocarAudioState();
}

class _BalaoTocarAudioState extends State<BalaoTocarAudio> {
  File arquivo;
  double posicaoSlider = 0.0;
  AudioPlayer player;
  AudioPlayerState playerState = AudioPlayerState.STOPPED;
  int duracao;
  double pontoAudio = 0.0;
  bool falhaAoCarregar = false;

  @override
  void initState() {
    startar();
    super.initState();
  }

  falhaAoCarregarAudio() {
    if (mounted) {
      setState(() {
        falhaAoCarregar = true;
      });
    }
  }

  startar() {
    player = new AudioPlayer();
    player.durationHandler = (_) {
      setState(() {
        duracao = _.inMilliseconds;
      });
    };
    widget.recurso.carregar((oArquivo) {
      setState(() {
        arquivo = oArquivo;
      });
    }, (_) {
      falhaAoCarregarAudio();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          getEsquerda(), getTopo(), getDireita(), getFundo()),
      child: Container(
        // key: widget.chaveUnica,
        decoration: ShapeDecoration(color: getCor(), shape: StadiumBorder()),
        child: getConteudo(),
      ),
    );
  }

  getConteudo() {
    if (falhaAoCarregar) {
      return conteudoFalha();
    }
    return conteudoOk();
  }

  conteudoFalha() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: getAlinhamento(),
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            print('refresca');
            setState(() {
              falhaAoCarregar = false;
            });
            startar();
          },
        ),
        Slider(
          activeColor: Colors.blueGrey,
          inactiveColor: Colors.blueGrey,
          onChanged: (double value) {},
          value: 0.0,
        )
      ],
    );
  }

  conteudoOk() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: getAlinhamento(),
      children: <Widget>[
        getIcone(),
        Slider(
          activeColor: Colors.blue,
          inactiveColor: Colors.blue,
          divisions: 10,
          label: pontoAudio.toString(),
          onChanged: (double value) {
            if (arquivo != null) {
              controleAudio(value);
            }
          },
          value: pontoAudio,
        )
      ],
    );
  }

  getCor() {
    return widget.recursoProprio
        ? Color.fromARGB(255, 150, 250, 150)
        : Colors.white;
  }

  getAlinhamento() {
    return widget.recursoProprio
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
  }

  double getDeslocamento() {
    return widget.recursoProprio ? Tela.x(context, 29) : Tela.x(context, 69);
  }

  getIcone() {
    if (arquivo != null) {
      return botaoAudio();
    } else {
      return CircularProgressIndicator();
    }
  }

  tocar() async {
    player.audioPlayerStateChangeHandler = (_) {
      setState(() {
        playerState = _;
      });
    };

    int resultado = await player.play(arquivo.path, isLocal: true);
    if (pontoAudio > 0 &&
        pontoAudio < 1 &&
        playerState != AudioPlayerState.COMPLETED) {
      player.seek(Duration(milliseconds: (pontoAudio * duracao).toInt()));
    }
    print('deu? $resultado');
    if (resultado == 1) {
      player.errorHandler = (_) {
        print(_);
      };
      player.durationHandler = (_) {
        if (duracao != _.inMilliseconds) {
          setState(() {
            duracao = _.inMilliseconds;
          });
        }
      };
      player.completionHandler = () {
        setState(() {
          pontoAudio = 0;
        });
      };
      player.positionHandler = (_) {
        setState(() {
          if (duracao != 0)
            pontoAudio = _.inMilliseconds / duracao;
          else
            pontoAudio = 0;
        });
      };
    }
  }

  continuarTocando() {
    player.seek(Duration(milliseconds: (pontoAudio * duracao).toInt()));
    player.resume();
  }

  pausar() {
    player.pause();
  }

  parar() {
    player.stop();
  }

  controleAudio(double _) async {
    setState(() {
      pontoAudio = _;
      if (playerState == AudioPlayerState.PLAYING) {
        pausar();
        continuarTocando();
      }
    });
  }

  getDireita() {
    return widget.recursoProprio ? 0.0 : Tela.x(context, 35);
  }

  getEsquerda() {
    return widget.recursoProprio ? Tela.x(context, 35) : 0.0;
  }

  getTopo() {
    return Tela.y(context, 1);
  }

  getFundo() {
    return Tela.y(context, 1);
  }

  Widget botaoAudio() {
    IconButton botao;
    switch (playerState) {
      case AudioPlayerState.STOPPED:
        botao = IconButton(
          icon: Icon(Icons.play_circle_filled),
          color: Colors.blueAccent,
          onPressed: () {
            tocar();
          },
        );
        break;
      case AudioPlayerState.PAUSED:
        botao = IconButton(
          icon: Icon(Icons.play_circle_filled),
          color: Colors.blueAccent,
          onPressed: () {
            continuarTocando();
          },
        );
        break;
      case AudioPlayerState.PLAYING:
        botao = IconButton(
          icon: Icon(Icons.pause_circle_filled),
          color: Colors.blueAccent,
          onPressed: () {
            pausar();
          },
        );
        break;
      case AudioPlayerState.COMPLETED:
        botao = IconButton(
          icon: Icon(Icons.play_circle_filled),
          color: Colors.blueAccent,
          onPressed: () {
            tocar();
          },
        );
        break;
    }
    return botao;
  }
}
