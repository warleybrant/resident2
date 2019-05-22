import 'dart:io';
import 'package:flutter/material.dart';
import 'package:resident/utils/tela.dart';

class ExibeImagem extends StatelessWidget {
  final String url;
  final File arquivo;
  final Function aoTocar;

  ExibeImagem({this.url, this.arquivo, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    var foto = arquivo != null
        ? Image.file(
            arquivo,
            width: Tela.x(context, 100),
            height: Tela.y(context, 100),
          )
        : Image.network(
            url,
            width: Tela.x(context, 100),
            height: Tela.y(context, 100),
          );

    return InkWell(
      child: foto,
      onTap: aoTocar,
    );
  }
}
