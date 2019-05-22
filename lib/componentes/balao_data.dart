import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resident/utils/tela.dart';

class BalaoData extends StatelessWidget {
  final DateTime data;
  BalaoData(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 35), vertical: Tela.y(context, 1)),
        child: Container(
          decoration:
              ShapeDecoration(color: Colors.tealAccent, shape: StadiumBorder()),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Tela.y(context, 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text(getDataFormatada())],
            ),
          ),
        ),
      ),
    );
  }

  String getDataFormatada() {
    return DateFormat('dd/MM/yyyy').format(data);
  }
}
