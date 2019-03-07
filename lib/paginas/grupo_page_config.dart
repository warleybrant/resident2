import 'package:flutter/material.dart';
import 'package:resident/componentes/foto_card.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/cores.dart';
import 'package:resident/utils/nucleo.dart';
import 'package:resident/utils/tela.dart';

class GrupoPage extends StatefulWidget {
  final PageController pagina;

  GrupoPage(this.pagina);

  @override
  _GrupoPageState createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  TextEditingController nomeGrupo = TextEditingController(text: '');
  Grupo grupo;
  GrupoEstado estado = GrupoEstado.CRIACAO;
  List contatosSelecionados = null;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (contatosSelecionados == null) {
      inicializarContatos();
      inicializarEstado();
    }
    return Scaffold(
      appBar: appBar(),
      body: corpo(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(Cores.FLOATING_BUTTON_BACKGROUND),
          foregroundColor: Color(Cores.FLOATING_BUTTON_FOREGROUND),
          child: Icon(Icons.done),
          onPressed: () {
            salvarGrupoESair();
          }),
    );
  }

  void inicializarEstado() {
    if (Grupo.mostrado == null) {
      estado = GrupoEstado.CRIACAO;
      Grupo.mostrado = Grupo();
    } else
      estado = GrupoEstado.ALTERACAO;
  }

  void inicializarContatos() {
    contatosSelecionados = [];
    contatosSelecionados.addAll(Grupo.mostrado.contatos);
  }

  Widget appBar() {
    if (Grupo.mostrado == null) return AppBar();
    return AppBar(
      title: Text(
          '${estado == GrupoEstado.CRIACAO ? "Criação de Grupo" : Grupo.mostrado.nome}'),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            voltar();
          }),
    );
  }

  Widget corpo() {
    if (Grupo.mostrado == null) return Container();
    return ListView(
      children: <Widget>[form()],
    );
  }

  Widget form() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          nomeGrupoInput(),
//          btnAddContato(),
          listaContatosSelecionados()
        ],
      ),
      key: _formKey,
    );
  }

  Widget nomeGrupoInput() {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 6), vertical: Tela.y(context, 1)),
        child: TextFormField(
          style: TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              border: InputBorder.none,
              labelText: 'Digite o nome do grupo'),
          // The validator receives the text the user has typed in
          validator: (value) {
            if (estado == GrupoEstado.CRIACAO) {
              if (value.isEmpty) return 'Nome do grupo está em branco';
            }
          },
          controller: nomeGrupo,
        ));
  }

  Widget btnAddContato() {
    return Center(
      child: FlatButton(
          onPressed: () {},
          child: Row(
            children: <Widget>[Icon(Icons.add), Text('Add contato')],
          )),
    );
  }

  Widget listaContatosSelecionados() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Tela.x(context, 5)),
      child: Container(
        color: Colors.white12,
        height: Tela.y(context, 60),
        child: ListView(
          children: contatosGrupo(),
        ),
      ),
    );
  }

  List<Widget> contatosGrupo() {
    List<Widget> lista = [];
    var contatosGrupo = Grupo.mostrado.getUsuariosContatos();
    contatosGrupo.forEach((contato) {
      lista.add(cardContato(contato));
    });
    Usuario.logado.usuariosContatos().forEach((Usuario logadoContato) {
      if (!contatosGrupo.contains(logadoContato)) {
        lista.add(cardContato(logadoContato));
      }
    });
    return lista;
  }

  Widget cardContato(Usuario contato) {
    return Card(
      child: CheckboxListTile(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FotoCard(contato.urlFoto, 80, 80),
            SizedBox(
              width: 20,
            ),
            Text(contato.getIdentificacao())
          ],
        ),
        value: contatosSelecionados.contains(contato.id),
        onChanged: (_) {
          setState(() {
            if (_) {
              if (!contatosSelecionados.contains(contato.id)) {
                contatosSelecionados.add(contato.id);
              }
            } else {
              contatosSelecionados.remove(contato.id);
            }
          });
        },
      ),
    );
  }

  void salvarGrupoESair() {
    if (_formKey.currentState.validate()) {
      if (nomeGrupo.text.isNotEmpty) Grupo.mostrado.nome = nomeGrupo.text;
      if (!contatosSelecionados.contains(Usuario.logado.id))
        contatosSelecionados.add(Usuario.logado.id);
      Grupo.mostrado.setContatosPelosIds(contatosSelecionados);
      Grupo.mostrado.salvar();
      voltar();
    }
  }

  void voltar() {
    Grupo.mostrado = null;
    nomeGrupo.clear();
    contatosSelecionados.clear();
    widget.pagina.jumpToPage(Paginas.GRUPOS);
    widget.pagina.jumpToPage(Paginas.GRUPOS);
    Nucleo.atualizaTela();
  }
}

enum GrupoEstado { CRIACAO, ALTERACAO }
