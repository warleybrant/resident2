import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/intercorrencia.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';

class IntercorrenciasPage extends StatefulWidget {
  @override
  _IntercorrenciasPageState createState() => _IntercorrenciasPageState();
}

class _IntercorrenciasPageState extends State<IntercorrenciasPage> {
  TextEditingController _controllerTexto = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();

  List<Intercorrencia> _intercorrencias = [];

  @override
  void initState() {
    Firestore.instance
        .collection('intercorrencias')
        .where('pacienteId', isEqualTo: Paciente.mostrado.id)
        .snapshots()
        .listen((snap) {
      if (snap.documents.length > 0) {
        List<Intercorrencia> intercorrencias = [];
        snap.documents.forEach((documento) {
          intercorrencias.add(Intercorrencia(
              documento.data['pacienteId'], documento.data['texto']));
        });
        if (mounted) {
          setState(() {
            _intercorrencias = intercorrencias;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return montaPagina();
  }

  Widget montaPagina() {
    return Scaffold(
      appBar: getAppBar(),
      body: getCorpo(),
      floatingActionButton: getBotoes(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      title: Text('${Paciente.mostrado.nome} - Intercorrências'),
    );
  }

  Widget getCorpo() {
    List<Widget> widgets = [];

    widgets.add(ListView(
      children: [getForm()],
    ));

    return Stack(
      children: widgets,
    );
  }

  Widget getForm() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getListaCampos(),
      ),
      key: _formKey,
    );
  }

  List<Widget> getListaCampos() {
    return [
      getCampoEscrever(),
      listaIntercorrencias(),
    ];
  }

  Widget getBotoes() {
    return FloatingActionButton(
      backgroundColor: Colors.redAccent,
      child: Icon(Icons.add_alert),
      onPressed: () {
        if (okParaDisparar()) {
          disparar();
        }
      },
    );
  }

  bool okParaDisparar() {
    return _formKey.currentState.validate();
  }

  void disparar() {
    Intercorrencia intercorrencia =
        Intercorrencia(Paciente.mostrado.id, _controllerTexto.text);
    intercorrencia.disparar();
    voltar();
  }

  void voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTE);
  }

  Widget getCampoEscrever() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 6), vertical: Tela.y(context, 2)),
      child: Container(
        height: Tela.y(context, 15),
        child: TextFormField(
          controller: _controllerTexto,
          maxLines: 3,
          maxLengthEnforced: true,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
              labelText: 'Digite aqui a intercorrência'),
          validator: (_) {
            if (_.isEmpty) {
              return 'Texto da intercorrência não pode ser vazio';
            }
            if (_.length < 3) {
              return 'Texto muito curto';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget listaIntercorrencias() {
    List<Widget> intercorrenciaWidgets = [];

    _intercorrencias.forEach((intercorrencia) {
      intercorrenciaWidgets.add(getCardIntercorrencia(intercorrencia));
    });

    return Padding(
      padding: EdgeInsets.only(
        left: Tela.x(context, 2.5),
        right: Tela.x(context, 2.5),
      ),
      child: Container(
        height: Tela.y(context, 55),
        child: ListView(
          children: intercorrenciaWidgets,
        ),
      ),
    );
  }

  Widget getCardIntercorrencia(Intercorrencia intercorrencia) {
    return Card(
      // key: UniqueKey(),
      child: ListTile(
        title: Text(intercorrencia.texto),
      ),
    );
  }
}
