import 'package:flutter/material.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/usuario.dart';
import '../utils/tela.dart';

class BubbleTexto extends StatelessWidget {
  final Mensagem msg;
  final BuildContext context;
  BubbleTexto(this.context, this.msg);

  @override
  Widget build(BuildContext context) {
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
    return msg.autor.id == Usuario.logado.id;
  }

  Color getCor() {
    return eMinha() ? Color.fromARGB(255, 150, 250, 150) : Colors.white;
  }

  EdgeInsets getMargem() {
    return EdgeInsets.fromLTRB(
        getEsquerda(), getTopo(), getDireita(), getFundo());
  }
}
