import 'package:flutter/material.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/usuario.dart';
import '../utils/tela.dart';

class BubbleAudio extends StatelessWidget {
  final Mensagem mensagem;
  final double pontoAudio;
  final bool tocando;
  final bool pausado;
  final BuildContext context;
  final Function(double) aoMudarPonto;
  final Function aoTocar;
  final Function aoPausar;

  BubbleAudio(this.context, this.mensagem, this.pontoAudio, this.tocando,
      this.pausado, this.aoMudarPonto, this.aoTocar, this.aoPausar);

  @override
  Widget build(BuildContext context) {
    return corpo();
  }

  corpo() {
    List<Widget> lista = !eMinha()
        ? <Widget>[
            cardPrincipal(),
            Expanded(
              child: Container(),
            )
          ]
        : <Widget>[
            Expanded(
              child: Container(),
            ),
            cardPrincipal(),
          ];
    return Row(
      children: lista,
    );
  }

  cardPrincipal() {
    return Card(
      key: UniqueKey(),
      // margin: getMargem(),
      color: getCor(),
      elevation: 5,
      borderOnForeground: true,
      child: Container(
        decoration: getDecoracaoBalao(),
        margin: EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: getAlinhamento(),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(mensagem.autor.getIdentificacao(), style: getEstiloAutor()),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getBotao(),
                Slider(
                  value: pontoAudio,
                  onChanged: aoMudarPonto,
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              Text(mensagem.horaFormatada(), style: getEstiloData())
            ])
          ],
        ),
      ),
    );
  }

  getBotao() {
    Widget btnTocar;
    if (!tocando || pausado) {
      btnTocar = IconButton(
          icon: Icon(
            Icons.play_circle_filled,
            color: eMinha() ? Colors.redAccent : Colors.blue,
          ),
          onPressed: () {
            aoTocar();
          });
    } else {
      btnTocar = IconButton(
          icon: Icon(
            Icons.pause_circle_filled,
            color: eMinha() ? Colors.redAccent : Colors.blue,
          ),
          onPressed: () {
            aoPausar();
          });
    }

    return btnTocar;
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
    double deslocamento = eMinha() ? Tela.x(context, 0) : Tela.x(context, 40);
    // deslocamento -= mensagem.texto.length * 1.5;
    // deslocamento -= mensagem.autor.getIdentificacao().length;
    // double x = !eMinha() ? deslocamento : Tela.x(context, 1);
    // if (!eMinha()) if (x < Tela.x(context, 10)) x = Tela.x(context, 10);
    return deslocamento;
  }

  double getEsquerda() {
    double deslocamento = eMinha() ? Tela.x(context, 40) : 0;
    // deslocamento -= mensagem.texto.length * 5;
    // deslocamento -= mensagem.autor.getIdentificacao().length;
    // if (deslocamento > Tela.x(context, 85)) deslocamento = Tela.x(context, 85);
    // double x = eMinha() ? deslocamento : Tela.x(context, );
    // if (eMinha()) if (x < Tela.x(context, 10)) x = Tela.x(context, 10);
    return deslocamento;
  }

  bool eMinha() {
    return mensagem.autor.id == Usuario.logado.id;
  }

  Color getCor() {
    return eMinha() ? Color.fromARGB(255, 150, 250, 150) : Colors.white;
  }

  EdgeInsets getMargem() {
    return EdgeInsets.fromLTRB(
        getEsquerda(), getTopo(), getDireita(), getFundo());
  }
}
