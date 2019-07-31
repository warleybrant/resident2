// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resident/utils/download_upload.dart';

class FotoCard extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  FotoCard(this.url, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    int tamUrl = url.length;
    String extensao = '';
    String caminho = '';

    if (tamUrl > 4) {
      extensao = url.substring(tamUrl - 3, tamUrl);
      // caminho = '${DownloadUpload.imagesPath}$id.$extensao';
    }

    File f = File(caminho);
    if (f.existsSync()) return widgetFotoCarregada(f);

    return FutureBuilder(
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) return widgetFotoCarregada(snap.data);
          // else
          // return
        }
        return SizedBox(
          width: width,
          height: height,
          child: CircleAvatar(
            child: Icon(Icons.add_a_photo),
          ),
        );
      },
      future: carregaArquivoFoto(),
    );
  }

  widgetFotoCarregada(File f) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: Image.file(f).image,
          ),
        ),
      ),
    );
  }

  Future<File> carregaArquivoFoto() {}
}
