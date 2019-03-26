import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resident/utils/download_upload.dart';

class SoundBubble extends StatefulWidget {
  String identificador;
  String url;

  @override
  _SoundBubbleState createState() => _SoundBubbleState();
}

class _SoundBubbleState extends State<SoundBubble> {
  File arquivo;

  @override
  void initState() {
    File f = new File(DownloadUpload.tempDirPath + widget.identificador);
    if (!f.existsSync()) {
      DownloadUpload.download('audios', widget.identificador).then((arq) {
        if (mounted) {
          setState(() {
            arquivo = arq;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getSoundWidget();
  }

  Widget getSoundWidget() {
    if (arquivo == null) return CircularProgressIndicator();
    return Container();
  }
}
