import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:resident/utils/tela.dart';

class ExibeImagem extends StatelessWidget {
  final String url;
  final Uint8List bytes;
  final Function aoTocar;

  ExibeImagem({this.url, this.bytes, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    var foto = bytes != null
        ? Image.memory(
            bytes,
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
