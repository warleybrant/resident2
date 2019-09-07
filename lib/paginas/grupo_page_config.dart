import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:resident/componentes/avatar_alteravel.dart';
import 'package:resident/componentes/exibe_imagem.dart';
import 'package:resident/componentes/photocard.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/cores.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';

class GrupoPage extends StatefulWidget {
  GrupoPage();

  @override
  _GrupoPageState createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  TextEditingController nomeGrupo = TextEditingController(text: '');
  Grupo grupo;
  bool carregando = false;
  bool salvandoImagem = false;
  Uint8List _bytesArquivoFoto;
  double progressoUpload = 0;
  List contatosSelecionados;
  final _formKey = GlobalKey<FormState>();
  String urlFotoMostrando;
  Uint8List _bytesFotoMostrar;

  @override
  void initState() {
    if (Grupo.mostrado == null) Grupo.mostrado = Grupo();
    if (Grupo.mostrado.contatos == null) Grupo.mostrado.contatos = [];
    contatosSelecionados = List.from(Grupo.mostrado.contatos);
    nomeGrupo.text = Grupo.mostrado.nome;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return montaPagina();
  }

  Widget montaPagina() {
    if (carregando) {
      return Stack(
        children: <Widget>[
          getScaffold(),
          Opacity(
            opacity: 0.7,
            child: Container(
              color: Colors.black,
            ),
          ),
          getIndicadorProgresso()
        ],
      );
    }
    return getScaffold();
  }

  Widget getIndicadorProgresso() {
    return Center(
      child: Card(
        child: Container(
          width: Tela.x(context, 20),
          height: Tela.y(context, 10),
          child: InkWell(
            child: Center(
              child: CircularProgressIndicator(),
            ),
            onTap: () {
              setState(() {
                carregando = false;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget getScaffold() {
    return Scaffold(
      appBar: appBar(),
      body: getCorpo(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(Cores.FLOATING_BUTTON_BACKGROUND),
          foregroundColor: Color(Cores.FLOATING_BUTTON_FOREGROUND),
          child: Icon(Icons.done),
          onPressed: () {
            salvarGrupoESair();
          }),
    );
  }

  Widget appBar() {
    String texto = "Criação de Grupo";

    if (Grupo.mostrado != null && Grupo.mostrado.nome != null) {
      texto = Grupo.mostrado.nome;
    }

    return AppBar(
      title: Text(texto),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            voltar();
          }),
      actions: getListaAcoes(),
    );
  }

  List<Widget> getListaAcoes() {
    if (Grupo.mostrado != null && Grupo.mostrado.id == null) return [];
    return [
      getBotaoAcaoExcluirGrupo(),
      getBotaoSairDoGrupo(),
    ];
  }

  getBotaoSairDoGrupo() {
    return RotatedBox(
      quarterTurns: 2,
      child: IconButton(
        icon: Icon(Icons.backspace),
        onPressed: () async {
          if ((await popupConfirmaSaida())) {
            Grupo.mostrado.sair();
            voltarParaGruposPage();
          }
        },
      ),
    );
  }

  voltarParaGruposPage() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.GRUPOS);
  }

  Widget getBotaoAcaoExcluirGrupo() {
    return FlatButton(
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () async {
        if ((await popupConfirmaExclusao())) {
          Grupo.mostrado.contatos = [];
          Grupo.mostrado.salvar();
          Grupo.mostrado.deletar();
          voltarParaGruposPage();
        }
      },
    );
  }

  Future<bool> popupConfirmaSaida() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Se você confirmar, irá sair do grupo. Confirma?'),
            actions: <Widget>[
              getBotaoConfirmaSaidaPopup(),
              getBotaoCancelaDeletePopup()
            ],
          );
        });
  }

  Future<bool> popupConfirmaExclusao() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
                'Se você confirmar, irá apagar definitivamente todos os pacientes e todo o conteúdo. Confirma?'),
            actions: <Widget>[
              getBotaoConfirmaDeletePopup(),
              getBotaoCancelaDeletePopup()
            ],
          );
        });
  }

  Widget getBotaoConfirmaSaidaPopup() {
    return RotatedBox(
      quarterTurns: 2,
      child: FlatButton(
        child: Icon(
          Icons.backspace,
          color: Colors.red,
        ),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }

  Widget getBotaoConfirmaDeletePopup() {
    return FlatButton(
      child: Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget getBotaoCancelaDeletePopup() {
    return FlatButton(
      child: Icon(Icons.close),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
  }

  Widget getCorpo() {
    if (Grupo.mostrado == null) return Container();
    var _lista = <Widget>[];
    _lista.add(ListView(
      children: <Widget>[form()],
    ));

    if (_bytesFotoMostrar != null) {
      _lista.add(Opacity(
        opacity: 0.4,
        child: Container(
          color: Colors.black,
        ),
      ));
      _lista.add(ExibeImagem(
        bytes: _bytesFotoMostrar,
        aoTocar: () {
          setState(() {
            _bytesFotoMostrar = null;
          });
        },
      ));
    }

    return Stack(
      children: _lista,
    );
  }

  Widget form() {
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

  getListaCampos() {
    return <Widget>[
      SizedBox(
        height: Tela.y(context, 1),
      ),
      Center(
        child: InkWell(
          child: fotoGrupo(),
          onTap: () {
            setState(() {
              if (_bytesFotoMostrar != null) {
                setState(() {
                  _bytesFotoMostrar = _bytesArquivoFoto;
                });
              } else {
                setState(() {
                  urlFotoMostrando = Grupo.mostrado.getUrlFoto();
                });
              }
            });
          },
        ),
      ),
      SizedBox(
        height: Tela.y(context, 1),
      ),
      nomeGrupoInput(),
      listaContatosSelecionados()
    ];
  }

  fotoGrupo() {
    return AvatarAlteravel(
      Tela.x(context, 40),
      Tela.x(context, 40),
      Grupo.mostrado.getUrlFoto(),
      _bytesArquivoFoto,
      aoSelecionarImagem: (File arquivoSelecionado) {
        if (mounted) {
          setState(() {
            if (arquivoSelecionado != null) {
              _bytesArquivoFoto = arquivoSelecionado.readAsBytesSync();
              salvandoImagem = true;
            }
            carregando = false;
          });
        }
      },
      aoBuscarImagem: () {
        setState(() {
          carregando = true;
        });
      },
    );
  }

  Widget nomeGrupoInput() {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 6), vertical: Tela.y(context, 1)),
        child: TextFormField(
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
              labelText: 'Digite o nome do grupo'),
          // The validator receives the text the user has typed in
          validator: (value) {
            if (Grupo.mostrado.id == null) {
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
        height: Tela.y(context, 40),
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
            PhotoCard(
                url: contato.getUrlFoto(),
                largura: Tela.x(context, 10),
                altura: Tela.x(context, 10)),
            SizedBox(
              width: Tela.x(context, 1),
            ),
            SizedBox(
              width: Tela.x(context, 40),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(contato.getIdentificacao()),
              ),
            )
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
      setState(() {
        carregando = true;
      });
      if (nomeGrupo.text.isNotEmpty) Grupo.mostrado.nome = nomeGrupo.text;
      if (!contatosSelecionados.contains(Usuario.logado.id))
        contatosSelecionados.add(Usuario.logado.id);
      Grupo.mostrado.setContatosPelosIds(contatosSelecionados);
      Grupo.mostrado.salvar(
          bytesFoto: _bytesArquivoFoto,
          progresso: (_) {
            if (mounted) {
              setState(() {
                progressoUpload = _;
              });
            }
          },
          aoSalvarFotoNoServidor: () {
            if (mounted) {
              setState(() {
                salvandoImagem = false;
              });
              FocusScope.of(context).requestFocus(new FocusNode());
              voltar();
            }
          });
      if (_bytesArquivoFoto == null) {
        FocusScope.of(context).requestFocus(new FocusNode());
        voltar();
      }
    }
  }

  void voltar() {
    Grupo.mostrado = null;
    voltarParaGruposPage();
  }
}
