import 'package:flutter/material.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/home_page.dart';
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

  @override
  void initState() {
    nomeController.text = Usuario.logado.nome;
    emailController.text = Usuario.logado.email;
    telefoneController.text = Usuario.logado.telefone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getTitulo(),
      body: getCorpo(),
      floatingActionButton: getBotaoSalvar(),
    );
  }

  Widget getTitulo() {
    return AppBar(
        title: Text('Perfil'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              voltar();
            }));
  }

  Widget getCorpo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Tela.x(context, 5)),
      child: Form(
        key: _formKey,
        child: ListView(
          children: listaCampos(),
        ),
      ),
    );
  }

  Widget getBotaoSalvar() {
    return FloatingActionButton(
      child: Icon(Icons.done),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          salvar();
          voltar();
        }
      },
    );
  }

  List<Widget> listaCampos() {
    return [
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
    return TextFormField(
      controller: nomeController,
      decoration:
          getCampoDecoration(label: 'Nome:', icone: Icons.account_circle),
      style: getCampoStyle(),
      validator: (_) {
        if (_.isEmpty) return 'Campo nome não pode ser vazio';
      },
    );
  }

  Widget getCampoEmail() {
    return TextFormField(
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
              if (sufixo.length < 2 || sufixo[1].isEmpty) return emailIncorreto;
            }
          }

          return null;
        });
  }

  Widget getCampoTelefone() {
    return TextFormField(
      enabled: false,
      controller: telefoneController,
      decoration: getCampoDecoration(label: 'Telefone', icone: Icons.phone),
      style: getCampoStyle(),
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
    }
  }

  void voltar() {
    if (_formKey.currentState.validate()) {
      HomePage.mudarPagina(Paginas.GRUPOS);
    }
  }
}
