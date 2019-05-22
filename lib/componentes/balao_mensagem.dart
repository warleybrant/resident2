import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:resident/componentes/balao_tocar_audio.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';

class BalaoMensagem extends StatefulWidget {
  final Mensagem msg;
  // final UniqueKey chaveUnica;
  final Function aoTocar;
  final Function feedback;
  BalaoMensagem(this.msg, {this.aoTocar, this.feedback});
  @override
  _BalaoMensagemState createState() => _BalaoMensagemState();
}

class _BalaoMensagemState extends State<BalaoMensagem> {
  Mensagem msg;
  int atualizacoes = 0;

  @override
  void initState() {
    msg = widget.msg;

    Firestore.instance
        .document('mensagens/${widget.msg.id}')
        .snapshots()
        .listen((snap) {
      if (snap != null) {
        setState(() {
          msg = Mensagem.deSnap(snap);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getCorpo();
  }

  Widget getCorpo() {
    if (msg.tipo == TipoMensagem.AUDIO) return getCorpoTipoAudio();
    if (msg.tipo == TipoMensagem.IMAGEM) return getCorpoTipoImagem();
    return getCorpoTipoTexto();
  }

  Widget getCorpoTipoAudio() {
    return BalaoTocarAudio(msg.recursoMidia, eMinha());
  }

  Widget getCorpoTipoImagem() {
    return Card(
      key: UniqueKey(),
      margin: getMargem(),
      color: getCor(),
      elevation: 5,
      borderOnForeground: true,
      child: Container(
        height: Tela.y(context, 5),
        child: IconButton(
          icon: Icon(
            Icons.image,
            color: Colors.black,
          ),
          onPressed: () {
            if (widget.aoTocar != null) {
              widget.aoTocar();
            }
            widget.msg.recursoMidia.carregar((arquivo) {
              OpenFile.open(arquivo.path).then((a) {
                Navigator.pushNamed(context, Paginas.EXAMES);
              }).then((_) {
                if (widget.feedback != null) {
                  widget.feedback();
                }
              });
            }, (erro) {
              print(erro.toString());
            });
          },
        ),
      ),
    );
  }

  Widget getCorpoTipoTexto() {
    return Card(
        key: UniqueKey(),
        margin: getMargem(),
        color: getCor(),
        elevation: 5,
        borderOnForeground: true,
        child: Container(
            decoration: getDecoracaoBalao(),
            margin: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: getAlinhamento(),
              children: <Widget>[
                Text(msg.autor.getIdentificacao(), style: getEstiloAutor()),
                Text(
                  msg.texto,
                  style: getEstiloMensagem(),
                ),
                SizedBox(height: 5),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(msg.horaFormatada(), style: getEstiloData())
                    ])
              ],
            )));
  }

  getDecoracaoBalao() {
    return ShapeDecoration(color: getCor(), shape: StadiumBorder());
  }

  getEstiloAutor() {
    return TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
  }

  getEstiloMensagem() {
    return TextStyle(fontSize: 16);
  }

  getEstiloData() {
    return TextStyle(fontSize: 12, color: Colors.blueGrey);
  }

  CrossAxisAlignment getAlinhamento() {
    return CrossAxisAlignment.start;
    // return !eMinha() ? CrossAxisAlignment.start : CrossAxisAlignment.end;
  }

  double getTopo() {
    return Tela.y(context, 0.5);
  }

  double getFundo() {
    return Tela.y(context, 0.5);
  }

  double getDireita() {
    double deslocamento = Tela.x(context, 80);
    deslocamento -= msg.texto.length * 1.5;
    deslocamento -= msg.autor.getIdentificacao().length;
    double x = !eMinha() ? deslocamento : Tela.x(context, 1);
    if (!eMinha()) if (x < Tela.x(context, 10)) x = Tela.x(context, 10);
    return x;
  }

  double getEsquerda() {
    double deslocamento = Tela.x(context, 80);
    deslocamento -= msg.texto.length * 5;
    deslocamento -= msg.autor.getIdentificacao().length;
    if (deslocamento > Tela.x(context, 85)) deslocamento = Tela.x(context, 85);
    double x = eMinha() ? deslocamento : Tela.x(context, 1);
    if (eMinha()) if (x < Tela.x(context, 10)) x = Tela.x(context, 10);
    return x;
  }

  bool eMinha() {
    return widget.msg.autor.id == Usuario.logado.id;
  }

  Color getCor() {
    return eMinha() ? Color.fromARGB(255, 150, 250, 150) : Colors.white;
  }

  EdgeInsets getMargem() {
    return EdgeInsets.fromLTRB(
        getEsquerda(), getTopo(), getDireita(), getFundo());
  }
}
