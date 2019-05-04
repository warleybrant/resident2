import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/cores.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';
import 'package:universal_widget/universal_widget.dart';

class ContatosPage extends StatefulWidget {
  ContatosPage();

  @override
  _ContatosPageState createState() => _ContatosPageState();
}

class _ContatosPageState extends State<ContatosPage> {
  ContatosEstado estado = ContatosEstado.NORMAL;
  UniversalWidget popup;
  UniversalWidget deleteContato;
  TextEditingController buscaContatoController =
      TextEditingController(text: '');
  Usuario contatoEncontrado;
  TextEditingController telefoneContatoContr = TextEditingController(text: '');
  var telefoneController =
      new MaskedTextController(mask: '+55 (00) 00000-0000', text: '+55');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return montaPagina();
  }

  Widget montaPagina() {
    List<Widget> lista = [];
    lista.add(paginaScaffold());
    popup = popupAddContato();
    if (popup != null) {
      lista.add(modalPopup());
      lista.add(popup);
    } else if (deleteContato != null) {
      lista.add(modalPopup());
      lista.add(deleteContato);
    }
    return Stack(
      children: lista,
    );
  }

  Widget paginaScaffold() {
    return Scaffold(
      appBar: appBar(),
      persistentFooterButtons: botoesRodape(),
      body: corpo(),
    );
  }

  Widget appBar() {
    return AppBar(
      title: Text('Contatos'),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            voltar();
          }),
    );
  }

  voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.GRUPOS);
  }

  Widget corpo() {
    var lista = listaContatos();
    return ListView(
      children: lista,
    );
  }

  List<Widget> botoesRodape() {
    return [btnImportarContatos(), btnBuscaContato()];
  }

  Widget btnBuscaContato() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      // backgroundColor: Color(0xFF123456),
      onPressed: () {
        setState(() {
          estado = ContatosEstado.FILTRO;
        });
      },
    );
  }

  UniversalWidget popupAddContato() {
    switch (estado) {
      case ContatosEstado.NORMAL:
        return null;
      case ContatosEstado.FILTRO:
        return basePopupBuscaContato();
      default:
        return null;
    }
  }

  Widget basePopupBuscaContato() {
    return UniversalWidget(
      width: Tela.x(context, 85),
      height: Tela.y(context, 40),
      left: Tela.x(context, 7.5),
      top: Tela.y(context, 5),
      animateWhenUpdate: false,
    );
  }

  Widget cardContatoEncontrado() {
    if (contatoEncontrado == null) return Container();
    return Card(
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        leading: fotoContato(contatoEncontrado),
        title: Text(
          contatoEncontrado.nome,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget modalPopup() {
    return Opacity(
      opacity: .8,
      child: GestureDetector(
        onTap: () {
          cancelarDeleteDialog();
        },
        child: Container(color: Colors.black),
      ),
    );
  }

  void animarEntradaPopup() {
    Future.delayed(Duration(milliseconds: 10)).then((_) {
      popup.update(
          delay: .1,
          width: Tela.x(context, 85),
          height: Tela.y(context, 40),
          left: Tela.x(context, 7.5),
          top: Tela.y(context, 5),
          child: popupCorpo());
    });
  }

  Widget popupCorpo() {
    return Material(
      type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                popupTextField(),
                cardContatoEncontrado(),
              ],
            ),
            Positioned(
              child: popupBtns(),
              bottom: 0,
              right: 0,
            )
          ],
        ),
      ),
    );
  }

  Widget popupTextField() {
    return TextFormField(
      controller: telefoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          labelText: 'Telefone do contato',
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
    );
  }

  Widget popupBtns() {
    if (contatoEncontrado == null) {
      return FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          localizarContato();
        },
      );
    }
    return Row(
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            localizarContato();
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () {
            setState(() {
              adicionaContatoALista(contatoEncontrado);
            });
          },
        )
      ],
    );
  }

  void localizarContato() {
    Usuario usuario = Usuario.buscaPorTelefone(telefoneController.text);

    setState(() {
      contatoEncontrado = usuario;
      if (contatoEncontrado != null) {
        if (Usuario.logado.contatos.contains(contatoEncontrado.id))
          contatoEncontrado = null;
        else
          popup.update(child: popupCorpo());
      }
    });
  }

  Widget btnImportarContatos() {
    return RaisedButton(
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
    );
  }

  List<Widget> listaContatos() {
    List<Widget> contatosCards = [];
    Usuario.logado.usuariosContatos().forEach((contato) {
      contatosCards.add(cardContato(contato));
    });
    return contatosCards;
  }

  Widget cardContato(Usuario contato) {
    return Card(
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
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  contato.nome,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              FloatingActionButton(
                heroTag: contato.id,
                child: Icon(Icons.clear),
                backgroundColor: Colors.red,
                onPressed: () {
                  setState(() {
                    montaDeleteDialog(contato);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void montaDeleteDialog(Usuario contato) {
    deleteContato = UniversalWidget(
      x: Tela.x(context, 10),
      y: Tela.y(context, 10),
      width: Tela.x(context, 80),
      height: Tela.y(context, 20),
      animateWhenUpdate: false,
      padding: EdgeInsets.all(5),
      child: Stack(
        children: <Widget>[
          Card(
            child: Center(
              child: textoDeleteDialog(contato),
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: Icon(
              Icons.perm_contact_calendar,
              color: Colors.black,
              size: 40,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: botoesDeleteDialog(contato),
          )
        ],
      ),
    );
  }

  void cancelarDeleteDialog() {
    setState(() {
      popup = null;
      deleteContato = null;
      estado = ContatosEstado.NORMAL;
    });
  }

  Widget textoDeleteDialog(Usuario contato) {
    return Text(
      'Deseja remover ${contato.getIdentificacao()}?',
      style: TextStyle(fontSize: 20),
    );
  }

  Widget botoesDeleteDialog(Usuario contato) {
    return Row(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Usuario.logado.removerContato(contato);
            Usuario.logado.salvar();
            cancelarDeleteDialog();
          },
          child: Text(
            'Remover',
            style: TextStyle(
                color: Color(Cores.FONTE_CARD_DELETE_SIM), fontSize: 15),
          ),
        ),
        FlatButton(
          onPressed: () {
            cancelarDeleteDialog();
          },
          child: Text(
            'Cancelar',
            style: TextStyle(
                color: Color(Cores.FONTE_CARD_DELETE_CANCELAR), fontSize: 15),
          ),
        )
      ],
    );
  }

  Widget fotoContato(Usuario contato) {
    if (contato.urlFoto == null) return Icon(Icons.account_circle);
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(contato.urlFoto),
          )),
    );
  }

  void adicionaContatoALista(Usuario contatoEncontrado) {
    Usuario.logado.addContato(contatoEncontrado);
    Usuario.logado.salvar();
    estado = ContatosEstado.NORMAL;
    contatoEncontrado = null;
  }
}

enum ContatosEstado { NORMAL, FILTRO, DELETANDO_CONTATO }
