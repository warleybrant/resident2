import 'dart:math';

import 'package:flutter/material.dart';
import 'package:resident/utils/tela.dart';

class Teste1 extends StatefulWidget {
  @override
  _Teste1State createState() => _Teste1State();
}

class _Teste1State extends State<Teste1> {
  var list = <String>[];

  @override
  void initState() {
    criarBalao();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: corpo(),
    );
  }

  corpo() {
    return ListView(children: lista());
  }

  lista() {
    var _list = <Widget>[];
    list.forEach((item) {
      _list.add(Teste(item));
    });
    return _list;
  }

  criarBalao() {
    Future.delayed(Duration(seconds: 5)).then((_) {
      if (mounted) {
        setState(() {
          list = List.from(list);
          list.add('Texto ${list.length}');
        });
        criarBalao();
      }
    });
  }
}

class Teste extends StatefulWidget {
  final String texto;
  Teste(this.texto);
  @override
  _TesteState createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  double _valor = 0;

  @override
  void initState() {
    mudar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Tela.x(context, 10),
      height: Tela.y(context, 10),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Text(widget.texto),
          Slider(
            value: _valor,
            onChanged: (_) {
              _valor = _;
            },
          )
        ],
      ),
    );
  }

  void mudar() {
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      if (mounted) {
        setState(() {
          _valor = Random().nextDouble();
        });
        mudar();
      }
    });
  }
}
