import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/main.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthException excessaoAuth;
  String verificationId;
  FirebaseUser usuario;
  var _formKey = GlobalKey<FormState>();
  TextEditingController _smsCodeController = TextEditingController();
  var telefoneController =
      new MaskedTextController(mask: '+55 (00) 00000-0000', text: '+55');
  final String testSmsCode = '888888';
  bool carregando = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: listaContatosWidgets(),
      ),
    );
  }

  Widget listaContatosWidgets() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        avatarResidente(),
        colunaCampoTelefone(),
        botaoLogin()
      ],
    );
  }

  Widget avatarResidente() {
    return CircleAvatar(
      radius: 100,
      child: Image.asset(
        'imagens/ic_launcher.png',
      ),
    );
  }

  Widget colunaCampoTelefone() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[labelTelefone(), campoTelefone()],
    );
  }

  Widget labelTelefone() {
    return Text(
      'Digite seu telefone:',
      style: TextStyle(
        fontSize: 25,
        color: Colors.white,
      ),
    );
  }

  Widget campoTelefone() {
    TextStyle estilo = TextStyle(
      fontSize: 25,
      color: Colors.white,
    );
    return Form(
      key: _formKey,
      child: TextFormField(
        style: estilo,
        keyboardType: TextInputType.number,
        controller: telefoneController,
        validator: (_) {
          if (_.isEmpty) return 'Preencha seu telefone';
          if (_.length < 15) return 'Telefone inválido';
          return null;
        },
      ),
    );
  }

  Widget textoLogin() {
    return Text(
      'Login',
      style: TextStyle(color: Color(0xff005000), fontSize: 30),
    );
  }

  Widget botaoLogin() {
    return RaisedButton(
      child: textoLogin(),
//      color: Colors.redAccent,
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 10), vertical: Tela.y(context, 1)),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          FocusScope.of(context).requestFocus(new FocusNode());
          _testVerifyPhoneNumber();
        }
      },
    );
  }

  Future<void> _testVerifyPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      if (carregando) {
        Usuario usuario = Usuario.buscaPorId(user.uid);
        if (usuario == null) {
          usuario = new Usuario(
              id: user.uid,
              nome: '',
              uid: user.uid,
              telefone: telefoneFormatado(),
              urlFoto: null,
              idResidente: telefoneFormatado(),
              contatos: []);
          usuario.salvar();
        }
        Usuario.logado = usuario;
        prefs.setString('usuarioLogado', user.uid);
        Navigator.pushNamedAndRemoveUntil(
            context, Paginas.INICIAL, (r) => false);
      }
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        carregando = false;
        excessaoAuth = authException;
        if (authException.code == 'quotaExceeded') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Todas as chamadas deste dispositivo foram bloqueadas por atividade não usual. Tente novamente mais tarde'),
          ));
        } else if (authException.code == 'invalidPhoneNumber') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Número de telefone inválido'),
          ));
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(authException.message),
          ));
        }
        print(excessaoAuth.message);
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      // setState(() {
      //   carregado = false;
      // });
      this.verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
      detectaEmulador();
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // setState(() {
      //   carregado = false;
      // });
      this.verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
      detectaEmulador();
    };

    setState(() {
      carregando = true;
    });
    await _auth.verifyPhoneNumber(
        phoneNumber: telefoneFormatado(),
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void detectaEmulador() {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      deviceInfo.iosInfo.then((info) {
        if (!info.isPhysicalDevice) {
          loginSimulado();
        }
      });
    } else if (Platform.isAndroid) {
      deviceInfo.androidInfo.then((info) {
        if (!info.isPhysicalDevice) {
          loginSimulado();
        }
      });
    }
  }

  void loginSimulado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Usuario teste = Usuario.buscaPorTelefone('+5531000000000');
    if (teste != null) {
      prefs.setString('usuarioLogado', teste.id);
      Usuario.logado = teste;
      Navigator.pushNamedAndRemoveUntil(context, Paginas.INICIAL, (r) => false);
    } else {
      teste = Usuario(
          telefone: '+5531000000000',
          nome: 'Usuário teste emulador',
          email: 'teste@aaa.bbb.cc',
          contatos: [],
          uid: '000000000000000');
      teste.salvar();
    }
  }

  String telefoneFormatado() {
    return telefoneController.text
        .replaceAll(" ", "")
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("-", "");
  }
}
