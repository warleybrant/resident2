import 'package:flutter/material.dart';
import 'package:resident/utils/tela.dart';

class BotaoAnexar extends StatefulWidget {
  final Function aoAtivar;

  BotaoAnexar(this.aoAtivar);

  @override
  _BotaoAnexarState createState() => _BotaoAnexarState();
}

class _BotaoAnexarState extends State<BotaoAnexar> {
  EstagioAnexacao estagio = EstagioAnexacao.INATIVO;

  @override
  Widget build(BuildContext context) {
    return getCorpo();
  }

  getCorpo() {
    switch (estagio) {
      case EstagioAnexacao.INATIVO:
        return IconButton(
          icon: Icon(Icons.attach_file),
          onPressed: () {
            setState(() {
              estagio = EstagioAnexacao.ESCOLHA_TIPO;
            });
          },
        );
      case EstagioAnexacao.ESCOLHA_TIPO:
        widget.aoAtivar();
        return tiposAnexo();
      case EstagioAnexacao.ANEXANDO:
        break;
      default:
    }
  }

  tiposAnexo() {
    return Column(
      children: <Widget>[
        Container(
          color: Color(0xFF7B2D26),
          height: Tela.y(context, 10),
          width: Tela.x(context, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              botaoImagem(context),
              botaoArquivo(context),
            ],
          ),
        ),
        SizedBox(
          height: Tela.y(context, 10),
        )
      ],
    );
  }
}

botaoImagem(context) {
  return Container(
    child: IconButton(
      icon: Icon(Icons.image),
      iconSize: 40,
      // color: Colors.black,
      onPressed: () {},
    ),
    width: Tela.x(context, 15),
  );
}

botaoArquivo(context) {
  return Container(
    child: IconButton(
      icon: Icon(Icons.insert_drive_file),
      iconSize: 40,
      // color: Colors.black,
      onPressed: () {},
    ),
    width: Tela.x(context, 15),
  );
}

enum EstagioAnexacao { INATIVO, ESCOLHA_TIPO, ANEXANDO }
