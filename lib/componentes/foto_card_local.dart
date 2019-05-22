import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FotoCardLocal extends StatelessWidget {
  final File arquivo;
  final double width;
  final double height;

  FotoCardLocal(this.arquivo, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    var foto = arquivo != null ? Image.file(arquivo) : null;

    Widget fotoWidget = foto != null
        ? SizedBox(
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: foto.image,
                ),
              ),
            ),
          )
        : SizedBox(
            width: width,
            height: height,
            child: CircleAvatar(
              child: Icon(Icons.add_a_photo),
            ),
          );
    return fotoWidget;
  }
}
