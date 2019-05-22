import 'package:flutter/material.dart';
import 'package:resident/componentes/balao_mensagem.dart';
import 'package:resident/entidades/mensagem.dart';

class BubbleAudio extends StatelessWidget {
  final Mensagem mensagem;
  BubbleAudio(this.mensagem);

  @override
  Widget build(BuildContext context) {
    return BalaoMensagem(mensagem);
  }
}
