import 'dart:io';
import 'dart:typed_data';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FotoCardLocal extends StatelessWidget {
  final Uint8List bytes;
  final double width;
  final double height;

  FotoCardLocal(this.bytes, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    var foto = bytes != null ? Image.memory(bytes) : null;

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
