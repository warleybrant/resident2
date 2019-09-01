// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:resident/utils/ferramentas.dart';

class PhotoCard extends StatefulWidget {
  final String url;
  final double largura;
  final double altura;
  final Uint8List bytes;
  final Function(Uint8List) aoExibir;

  PhotoCard({this.url, this.largura, this.altura, this.aoExibir, this.bytes});
  @override
  _PhotoCardState createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  Uint8List _bytes;
  double _largura;
  double _altura;

  @override
  void initState() {
    _largura = widget.largura;
    _altura = widget.altura;
    _bytes = widget.bytes;
    if (_bytes == null) {
      carregaArquivo();
    }
    // if (_bytes != null)
    //   print('Número de bytes da foto selecionada: ${_bytes.lengthInBytes}');
    // else
    //   print('_bytes está nula');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null && _bytes.lengthInBytes > 0) {
      return widgetFotoCarregada();
    } else {
      carregaArquivo();
      return SizedBox(
        width: _largura,
        height: _altura,
        child: CircleAvatar(
          child: Icon(Icons.add_a_photo),
        ),
      );
    }
  }

  carregaArquivo() {
    Ferramentas.carregaArquivoAsync(widget.url, (arquivo) {
      if (mounted) {
        setState(() {
          _bytes = arquivo;
        });
      } else {
        _bytes = arquivo;
      }
    });
  }

  widgetFotoCarregada() {
    return InkWell(
      child: SizedBox(
        key: UniqueKey(),
        width: _largura,
        height: _altura,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Image.memory(
                _bytes,
                width: _largura,
                height: _altura,
              ).image,
            ),
          ),
        ),
      ),
      onTap: () {
        if (widget.aoExibir != null) {
          widget.aoExibir(_bytes);
        }
      },
    );
  }
}
