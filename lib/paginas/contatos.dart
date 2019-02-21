import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/home_page.dart';

class ContatosPage extends StatefulWidget {
  final PageController pagina;

  ContatosPage(this.pagina);

  @override
  _ContatosPageState createState() => _ContatosPageState();
}

class _ContatosPageState extends State<ContatosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              widget.pagina.jumpToPage(Paginas.GRUPOS);
            }),
      ),
      persistentFooterButtons: <Widget>[
        RaisedButton(
          elevation: 15,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Importar contatos\n da lista telefônica',
              style: TextStyle(fontSize: 18),
            ),
          ),
          color: Colors.yellow,
          onPressed: () {},
        )
      ],
      body: corpo(),
    );
  }

  Widget corpo() {
    return listaContatos();
  }

  Widget listaContatos() {
    List<Widget> contatosCards = [];
    Usuario.logado.usuariosContatos().forEach((contato) {
      contatosCards.add(Card(
        elevation: 5,
        child: Container(
          height: 80,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                fotoContato(contato),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    contato.nome,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ));
    });
    return ListView(children: contatosCards);
  }

  Widget fotoContato(Usuario contato) {
    if (contato.urlFoto == null) return Icon(Icons.account_circle);
    return Container(
      width: 60,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.contain,
            image: CachedNetworkImageProvider(contato.urlFoto),
          )),
    );
  }
}
