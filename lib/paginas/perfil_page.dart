import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:resident/componentes/avatar_alteravel.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_storage.dart';
import 'package:resident/utils/tela.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  var nomeController = TextEditingController(text: '');
  var emailController = TextEditingController(text: '');
  var telefoneController =
      MaskedTextController(text: '', mask: '+55(00)00000-0000');
  final _formKey = GlobalKey<FormState>();
  bool carregando = false;
  bool salvandoImagem = false;
  File arquivoImagem;
  double progressoUpload = 0;

  @override
  void initState() {
    nomeController.text = Usuario.logado.nome;
    emailController.text = Usuario.logado.email;
    telefoneController.text = Usuario.logado.telefone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _formKey.currentState.validate();
        return Future.value(podeVoltar());
      },
      child: Scaffold(
        appBar: getTitulo(),
        body: getCorpo(),
        floatingActionButton: getBotaoSalvar(),
      ),
    );
  }

  bool podeVoltar() {
    return Usuario.logado != null && Usuario.logado.camposPreenchidos();
  }

  Widget getTitulo() {
    var btnVoltar = podeVoltar()
        ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              voltar();
            })
        : null;
    return AppBar(title: Text('Perfil'), leading: btnVoltar);
  }

  Widget getCorpo() {
    var _lista = <Widget>[];
    _lista.add(ListView(
      children: <Widget>[form()],
    ));

    if (carregando) {
      _lista.add(Ferramentas.barreiraModal(() {
        setState(() {
          carregando = false;
        });
      }, porcentagem: progressoUpload / 100));
    }

    return Stack(
      children: _lista,
    );
  }

  form() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listaCampos(),
      ),
      key: _formKey,
    );
  }

  fotoUsuario() {
    return AvatarAlteravel(
      Tela.x(context, 40),
      Tela.x(context, 40),
      Usuario.logado.urlFoto,
      arquivoImagem,
      aoSelecionarImagem: (File arquivoSelecionado) {
        if (arquivoSelecionado != null) {
          setState(() {
            arquivoImagem = arquivoSelecionado;
            salvandoImagem = true;
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

  Widget getBotaoSalvar() {
    return FloatingActionButton(
      child: Icon(Icons.done),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          salvar();
          if (arquivoImagem == null) {
            voltar();
          }
        }
      },
    );
  }

  List<Widget> listaCampos() {
    return [
      SizedBox(
        height: Tela.y(context, 5),
      ),
      Center(
        child: fotoUsuario(),
      ),
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoNome(),
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoEmail(),
      SizedBox(
        height: Tela.y(context, 5),
      ),
      getCampoTelefone()
    ];
  }

  Widget getCampoNome() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 6), vertical: Tela.y(context, 1)),
      child: TextFormField(
        controller: nomeController,
        decoration:
            getCampoDecoration(label: 'Nome:', icone: Icons.account_circle),
        style: getCampoStyle(),
        validator: (_) {
          if (_.isEmpty) return 'Campo nome não pode ser vazio';
        },
      ),
    );
  }

  Widget getCampoEmail() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 6), vertical: Tela.y(context, 1)),
      child: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: getCampoDecoration(label: 'Email:', icone: Icons.email),
          style: getCampoStyle(),
          validator: (_) {
            if (_.isEmpty) return 'E-mail não pode ser vazio';
            var emailIncorreto = 'Formato de e-mail incorreto';
            if (!_.contains('@'))
              return emailIncorreto;
            else {
              var sufixo = _.split('@');
              if (sufixo[1].isEmpty || !sufixo[1].contains('.'))
                return emailIncorreto;
              else {
                sufixo = sufixo[1].toString().split('.');
                if (sufixo.length < 2 || sufixo[1].isEmpty)
                  return emailIncorreto;
              }
            }

            return null;
          }),
    );
  }

  Widget getCampoTelefone() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 6), vertical: Tela.y(context, 1)),
      child: TextFormField(
        enabled:
            Usuario.logado.telefone == null || Usuario.logado.telefone.isEmpty,
        controller: telefoneController,
        decoration: getCampoDecoration(label: 'Telefone', icone: Icons.phone),
        style: getCampoStyle(),
      ),
    );
  }

  TextStyle getCampoStyle() {
    return TextStyle();
  }

  InputDecoration getCampoDecoration({String label, IconData icone}) {
    return InputDecoration(
        labelText: label,
        fillColor: Colors.white,
        icon: Icon(icone),
        filled: true,
        border: OutlineInputBorder());
  }

  void salvar() {
    if (_formKey.currentState.validate()) {
      Usuario.logado.nome = nomeController.text;
      Usuario.logado.email = emailController.text;
      Usuario.logado.salvar();
      if (arquivoImagem != null) {
        setState(() {
          carregando = true;
        });
        String caminhoNoServidor =
            'fotos_capa/usuarios/${Usuario.logado.id}.png';
        ProxyStorage.uploadArquivo(
          arquivoImagem,
          caminhoNoServidor,
          progresso: (_) {
            setState(() {
              progressoUpload = _;
            });
          },
          aoSubir: (r) {
            var ref = FirebaseStorage.instance.ref().child(caminhoNoServidor);
            ref.getDownloadURL().then((_) {
              Usuario.logado.urlFoto = _;
              Usuario.logado.salvar();
              if (mounted) {
                setState(() {
                  carregando = false;
                });
              }
              voltar();
            });
          },
        );
      }
    }
  }

  void voltar() {
    // if (_formKey.currentState.validate()) {
    if (podeVoltar()) {
      Navigator.pushNamed(context, Paginas.GRUPOS);
    }
  }
}
