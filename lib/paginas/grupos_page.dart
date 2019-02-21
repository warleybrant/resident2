import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GruposPage extends StatefulWidget {
  final PageController pagina;

  GruposPage(this.pagina);

  @override
  _GruposPageState createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos'),
      ),
      body: listaGrupos(),
      drawer: Drawer(
        child: Column(
          children: drawerItens(),
        ),
      ),
      persistentFooterButtons: <Widget>[
        FloatingActionButton(
            backgroundColor: Colors.deepOrangeAccent,
            elevation: 8,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Grupo.mostrado = null;
              widget.pagina.jumpToPage(Paginas.GRUPO);
//              deslogar();
            })
      ],
    );
  }

  List<Widget> drawerItens() {
    TextStyle estilo = TextStyle(fontSize: 15);
    return [
      ListTile(
        title: Text(
          'Contatos',
          style: estilo,
        ),
        leading: Icon(Icons.group),
        onTap: () {
          Navigator.pop(context);
          widget.pagina.jumpToPage(3);
        },
      )
    ];
  }

  Widget listaGrupos() {
    if (Grupo.lista == null) return Container();
    List<Widget> gruposCard = [];
    Grupo.lista.forEach((grupo) {
      gruposCard.add(cardGrupo(grupo));
    });
    return ListView(
      children: gruposCard,
    );
  }

  void deslogar() {
    SharedPreferences.getInstance().then((_) {
      setState(() {
        _.remove('usuarioLogado');
      });
    });
  }

  Widget cardGrupo(Grupo grupo) {
    var foto = grupo.urlFoto != null
        ? CachedNetworkImageProvider(grupo.urlFoto, errorListener: () {})
        : null;

    Widget fotoGrupo = foto != null
        ? Container(
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: foto,
              ),
            ),
          )
        : SizedBox(
            width: 80,
            child: CircleAvatar(
              child: Icon(Icons.add_a_photo),
            ),
          );
    Widget textoGrupo = Expanded(
      child: MaterialButton(
          child: Text(grupo.nome),
          onPressed: () {
            Grupo.mostrado = grupo;
            widget.pagina.jumpToPage(Paginas.PACIENTES);
          }),
    );
    Widget configuracoesGrupo = RaisedButton(
      shape: CircleBorder(),
      color: Colors.white,
      child: Icon(Icons.build),
      onPressed: () {
        Grupo.mostrado = grupo;
        widget.pagina.jumpToPage(Paginas.GRUPO);
      },
    );
    List<Widget> lista = [fotoGrupo, textoGrupo, configuracoesGrupo];
    return Card(
      key: Key(grupo.id),
      elevation: 5,
      child: Container(
        height: 80,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: lista,
          ),
        ),
      ),
    );
  }
}
