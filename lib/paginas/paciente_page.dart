import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resident/componentes/balao_data.dart';
import 'package:resident/componentes/bubble.dart';
import 'package:resident/componentes/bubble_audio.dart';
import 'package:resident/componentes/bubble_imagem.dart';
import 'package:resident/componentes/bubble_texto.dart';
import 'package:resident/componentes/gravador_som.dart';
import 'package:resident/entidades/audio.dart';
import 'package:resident/entidades/exame.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/recurso_midia.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/download_upload.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_firestore.dart';
import 'package:resident/utils/tela.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';

class PacientePage extends StatefulWidget {
  PacientePage();

  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  int atualizacoes = 0;
  bool carregando = false;
  Mensagem mensagemTocando;
  double pontoAudio = 0;
  AudioPlayer player;
  AudioPlayerState playerState = AudioPlayerState.STOPPED;
  int duracao = 0;
  bool pausado = false;

  List<Widget> listBaloesMensagem() {
    List<BalaoData> baloesData = [];
    List<Widget> widgets = [];
    mensagens.forEach((mensagem) {
      String dataFormatada =
          DateFormat('dd/MM/yyyy').format(mensagem.horaCriacao);
      var balaoData = BalaoData(mensagem.horaCriacao);
      var widget;
      if (mensagem.tipo == TipoMensagem.TEXTO) {
        widget = BubbleTexto(context, mensagem);
      } else if (mensagem.tipo == TipoMensagem.AUDIO) {
        double _ponto = 0.0;
        bool _tocando = false;
        bool _pausado = false;
        if (mensagemTocando != null && mensagemTocando.id == mensagem.id) {
          _ponto = pontoAudio;
          _tocando = true;
          _pausado = pausado;
        }
        widget = BubbleAudio(
            context, mensagem, _ponto, _tocando, _pausado, aoMudarPonto, () {
          setState(() {
            pausado = false;
            mensagemTocando = mensagem;
            if (!_pausado)
              tocarAudio(mensagem.recursoMidia);
            else
              resumeAudio();
          });
        }, () {
          if (mounted) {
            setState(() {
              pausado = true;
              pausar();
            });
          }
        });
      } else if (mensagem.tipo == TipoMensagem.IMAGEM) {
        widget = BubbleImagem(context, mensagem, () {
          setState(() {
            carregando = true;
          });
          mensagem.recursoMidia.carregar((arquivo) {
            OpenFile.open(arquivo.path).then((a) {
              Navigator.pushNamed(context, Paginas.EXAMES);
            }).then((_) {
              setState(() {
                carregando = false;
              });
              // if (widget.feedback != null) {
              // widget.feedback();
              // }
            });
          }, (erro) {
            setState(() {
              carregando = false;
            });
            print(erro.toString());
          });
        });
      }
      if (!baloesData.any((BalaoData bal) {
        return bal.getDataFormatada() == dataFormatada;
      })) {
        baloesData.add(balaoData);
        widgets.add(balaoData);
      }
      widgets.add(widget);
    });

    return widgets;
  }

  void pausar() {
    player.pause();
  }

  void resumeAudio() {
    player.seek(Duration(milliseconds: (pontoAudio * duracao).toInt()));
    player.resume();
  }

  void tocarAudio(RecursoMidia recursoMidia) {
    recursoMidia.carregar((arquivo) async {
      player = new AudioPlayer();
      player.audioPlayerStateChangeHandler = (_) {
        if (mounted) {
          setState(() {
            playerState = _;
          });
        }
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
            resetAudio();
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
    }, (_) {});
  }

  void resetAudio() {
    setState(() {
      pontoAudio = 0;
      mensagemTocando = null;
      pausado = false;
      duracao = 0;
    });
  }

  void aoMudarPonto(_) {}
  void aoPausar() {}

  StreamSubscription streamGravacao;
  FlutterSound flutterSound = new FlutterSound();

  PacientePageEstado estado = PacientePageEstado.PARADO;
  TextEditingController barraTexto = TextEditingController(text: '');
  ScrollController listaMensagensController = ScrollController();

  int numMensagens = 0;
  List<Mensagem> mensagens = [];

  @override
  void initState() {
    listaMensagensController = ScrollController();
    listaMensagensController.addListener(eventoScrollMensagens);
    mensagens = Mensagem.porPaciente(Paciente.mostrado);
    ProxyFirestore.observar(Paginas.PACIENTE, () {
      if (mounted) {
        var _lista = <Mensagem>[];
        _lista.addAll(Mensagem.porPaciente(Paciente.mostrado));
        _lista.sort((m1, m2) => m1.horaCriacao.millisecondsSinceEpoch
            .compareTo(m2.horaCriacao.millisecondsSinceEpoch));
        setState(() {
          mensagens = _lista;
          print('mensagens atualizadas');
          if (listaMensagensController.hasClients) {
            print('descendo scroll');
            listaMensagensController.animateTo(
                listaMensagensController.position.maxScrollExtent,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOut);
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    ProxyFirestore.pararDeObservar(Paginas.PACIENTES);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Paciente.mostrado.nome),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Paciente.mostrado = null;
              voltar();
            }),
      ),
      endDrawer: getDrawer(),
      body: corpo(),
    );
  }

  Widget corpo() {
    var _lista = <Widget>[];
    _lista.add(corpoStackPrincipal());

    if (carregando) {
      _lista.add(Ferramentas.loading(aoTocar: () {
        setState(() {
          carregando = false;
        });
      }));
    }
    return Stack(
      children: _lista,
    );
  }

  corpoStackPrincipal() {
    return Stack(
      fit: StackFit.passthrough,
      overflow: Overflow.visible,
      children: <Widget>[
        ListView(
          children: <Widget>[
            Container(
              height: Tela.y(context, 80),
              // color: Colors.teal,
              child: mensagensWidget(),
            ),
            barraEscrita()
          ],
        ),
      ],
    );
  }

  eventoScrollMensagens() {
    if (listaMensagensController.offset >=
            listaMensagensController.position.maxScrollExtent &&
        !listaMensagensController.position.outOfRange) {
      setState(() {
        print("reach the bottom");
      });
    }
    if (listaMensagensController.offset <=
            listaMensagensController.position.minScrollExtent &&
        !listaMensagensController.position.outOfRange) {
      setState(() {
        print("reach the top");
      });
    }
  }

  Widget mensagensWidget() {
    var lista = listBaloesMensagem();
    var widget = ListView(
      controller: listaMensagensController,
      children: lista,
    );
    return widget;
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
      getOpcaoDrawer(
          texto: 'Intercorrência',
          iconeInicio: Icons.add_alert,
          vaiPara: Paginas.INTERCORRENCIAS,
          cor: Colors.redAccent),
      // getOpcaoDrawer(texto: 'Alta do paciente', iconeInicio: Icons.accessibility),
    ];
  }

  voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTES);
  }

  Widget getOpcaoDrawer(
      {String texto,
      IconData iconeInicio,
      IconData iconeFim,
      String vaiPara,
      @optionalTypeArgs Color cor}) {
    // if (cor == null) {
    //   cor = IconTheme.of(context).color;
    //   cor = cor.withOpacity(1.0);
    // }
    return ListTile(
      title: Text(texto),
      leading: Icon(
        iconeInicio,
        color: cor,
      ),
      trailing: Icon(iconeFim),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, vaiPara);
      },
    );
  }

  Widget barraEscrita() {
    var lista = [corpoBarra()];
    if (estado == PacientePageEstado.PARADO) {
      lista.add(SizedBox(
        width: Tela.x(context, 1.5),
      ));
      lista.add(botaoGravarAudio());
    } else if (estado == PacientePageEstado.ESCREVENDO) {
      lista.add(SizedBox(
        width: Tela.x(context, 1.5),
      ));
      lista.add(botaoEnviarMensagem());
    } else if (estado == PacientePageEstado.GRAVANDO_AUDIO) {
      lista.add(botaoGravarAudio());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
          padding: EdgeInsets.only(left: Tela.x(context, 7)),
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
      componentes.add(botaoCamera());
    } else if (estado == PacientePageEstado.ESCREVENDO ||
        estado == PacientePageEstado.GRAVANDO_AUDIO) {
      componentes.add(input());
      componentes.add(botaoCamera());
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
            grupo: Grupo.mostrado);
        mensagem.salvar();
        setState(() {
          barraTexto.text = '';
          estado = PacientePageEstado.PARADO;
        });
      },
    );
  }

  Widget botaoCamera() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.camera_alt),
      onPressed: () {
        pegarImagem(ImageSource.camera).then((arquivo) {
          criarExame(arquivo);
        });
      },
    );
  }

  Widget botaoAnexar() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.attach_file),
      onPressed: () {
        pegarImagem(ImageSource.gallery).then((arquivo) {
          criarExame(arquivo);
        });
      },
    );
  }

  criarExame(arquivo) {
    if (arquivo != null) {
      // print('###Tamnho do arquivo: ${arquivo.lengthSync()}###');
      List<String> partes = arquivo.path.split('.');
      String ultimaParte = partes.last;
      Mensagem msg;
      RecursoMidia recurso = RecursoMidia(
          tipo: TipoRecurso.IMAGEM,
          grupo: Paciente.mostrado.grupo,
          paciente: Paciente.mostrado,
          extensao: ultimaParte);
      recurso.salvar();

      recurso.upload(arquivo, aoSubir: (resultado) {
        msg.tipo = TipoMensagem.IMAGEM;
        msg.salvar();
        var exame = Exame(
            descricao: 'Imagem',
            data: DateTime.now(),
            paciente: Paciente.mostrado,
            recursoId: recurso.id);
        exame.salvar();
      }, progresso: (percentual) {
        msg.texto = '${percentual.toStringAsFixed(2)} %';
        print(msg.texto);
        msg.salvar();
      });

      msg = Mensagem(
          tipo: TipoMensagem.TEXTO,
          grupo: Grupo.mostrado,
          paciente: Paciente.mostrado,
          recursoMidia: recurso,
          texto: 'Enviando...');
      msg.salvar();
    }
  }

  Future<File> pegarImagem(ImageSource fonte) async {
    return await ImagePicker.pickImage(source: fonte);
  }

  Widget botaoTirarFoto() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.camera_alt),
      onPressed: () {},
    );
  }

  Widget botaoGravarAudio() {
    return Gravador(
      aposGravar: (arquivo) {
        if (arquivo != null) {
          print('###Tamnho do arquivo: ${arquivo.lengthSync()}###');
          List<String> partes = arquivo.path.split('.');
          String ultimaParte = partes.last;
          Mensagem msg;
          RecursoMidia recurso = RecursoMidia(
              tipo: TipoRecurso.AUDIO,
              grupo: Paciente.mostrado.grupo,
              paciente: Paciente.mostrado,
              extensao: ultimaParte);
          recurso.salvar();
          recurso.upload(arquivo, aoSubir: (resultado) {
            msg.tipo = TipoMensagem.AUDIO;
            msg.salvar();
          }, progresso: (percentual) {
            msg.texto = '${percentual.toStringAsFixed(2)} %';
            print(msg.texto);
            msg.salvar();
          });
          msg = Mensagem(
              tipo: TipoMensagem.TEXTO,
              grupo: Grupo.mostrado,
              paciente: Paciente.mostrado,
              recursoMidia: recurso,
              texto: 'Enviando...');
          msg.salvar();
        }
      },
    );
  }

  Widget botaoGravarAudio2() {
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
