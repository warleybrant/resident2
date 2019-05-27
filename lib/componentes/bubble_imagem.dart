import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/paginas.dart';
import '../utils/tela.dart';

class BubbleImagem extends StatelessWidget {
  final Mensagem mensagem;
  final BuildContext context;
  final Function aoTocar;
  // final Function feedback;
  BubbleImagem(this.context, this.mensagem, this.aoTocar);

  @override
  Widget build(BuildContext context) {
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
            aoTocar();
            // if (aoTocar != null) {
            //   aoTocar();
            // }
            // mensagem.recursoMidia.carregar((arquivo) {
            //   OpenFile.open(arquivo.path).then((a) {
            //     Navigator.pushNamed(context, Paginas.EXAMES);
            //   }).then((_) {
            //     if (feedback != null) {
            //       feedback();
            //     }
            //   });
            // }, (erro) {
            //   print(erro.toString());
            // });
          },
        ),
      ),
    );
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
    deslocamento -= mensagem.texto.length * 1.5;
    deslocamento -= mensagem.autor.getIdentificacao().length;
    double x = !eMinha() ? deslocamento : Tela.x(context, 1);
    if (!eMinha()) if (x < Tela.x(context, 10)) x = Tela.x(context, 10);
    return x;
  }

  double getEsquerda() {
    double deslocamento = Tela.x(context, 80);
    deslocamento -= mensagem.texto.length * 5;
    deslocamento -= mensagem.autor.getIdentificacao().length;
    if (deslocamento > Tela.x(context, 85)) deslocamento = Tela.x(context, 85);
    double x = eMinha() ? deslocamento : Tela.x(context, 1);
    if (eMinha()) if (x < Tela.x(context, 10)) x = Tela.x(context, 10);
    return x;
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
