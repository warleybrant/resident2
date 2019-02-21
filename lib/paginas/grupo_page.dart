import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/paginas/home_page.dart';

class GrupoPage extends StatefulWidget {
  final PageController pagina;

  GrupoPage(this.pagina);

  @override
  _GrupoPageState createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  TextEditingController nomeGrupo = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${Grupo.mostrado != null ? Grupo.mostrado.nome : "Criação de Grupo"}'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              widget.pagina.jumpToPage(Paginas.GRUPOS);
            }),
      ),
      body: Card(
        elevation: 10,
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nomeGrupo,
              ),
              Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text('teste'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
//        Grupo grupo = new Grupo(
//            nome: 'Teste', descricao: 'Teste Descrição', contatos: []);
//        grupo.salvar();
      }),
    );
  }
}
