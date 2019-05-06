import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FotoCard extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  FotoCard(this.url, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    var foto = url != null
        ? CachedNetworkImageProvider(url, errorListener: () {})
        : null;

    Widget fotoWidget = foto != null
        ? SizedBox(
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: foto,
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
