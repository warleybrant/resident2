import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:resident/entidades/usuario.dart';
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
  String _verificationId;
  FirebaseUser usuario;
  var _formKey = GlobalKey<FormState>();
  TextEditingController _smsCodeController = TextEditingController(text: '');
  TextEditingController _pinController = TextEditingController(text: '');
  var telefoneController =
      new MaskedTextController(mask: '+55 (00) 00000-0000', text: '+55');
  final String testSmsCode = '888888';
  bool carregando = false;
  bool _sms = false;

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
            opacity: 1,
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
      backgroundColor: Colors.teal[300],
      body: _getCorpo(),
    );
  }

  Widget _getCorpo() {
    List<Widget> lista = [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: listaContatosWidgets(),
      )
    ];
    if (_sms) {
      lista.add(
        Opacity(
          opacity: 0.8,
          child: InkWell(
            onTap: () {
              setState(() {
                cancelaSms();
              });
            },
            child: Container(
              color: Colors.black,
            ),
          ),
        ),
      );
      lista.add(pinView());
    }
    return Stack(
      children: lista,
    );
  }

  Widget listaContatosWidgets() {
    var lista = <Widget>[
      avatarResidente(),
      colunaCampoTelefone(),
      botaoLogin()
    ];
    if (_verificationId != null) {
      lista.add(botaoDigitarPin());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: lista,
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

  Widget pinView() {
    return Center(
      child: Card(
        child: Container(
          width: Tela.x(context, 70),
          height: Tela.y(context, 12),
          color: Colors.white,
          child: Center(
            child: PinCodeTextField(
              autofocus: true,
              controller: _smsCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              pinBoxWidth: 40,
              defaultBorderColor: Colors.blueGrey,
              hasTextBorderColor: Colors.cyanAccent,
              // highlightColor: Colors.white,
              highlight: true,
              pinBoxDecoration:
                  ProvidedPinBoxDecoration.defaultPinBoxDecoration,
              pinTextStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              onDone: (_) {
                AuthCredential auth = PhoneAuthProvider.getCredential(
                    smsCode: _, verificationId: _verificationId);
                FirebaseAuth.instance
                    .signInWithCredential(auth)
                    .catchError((_) {
                  print(_);
                }).then((_) {
                  loginComFirebaseUser(_);
                });
              },
            ),
          ),
        ),
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

  Widget botaoDigitarPin() {
    return RaisedButton(
      child: textoDigitarSms(),
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 10), vertical: Tela.y(context, 1)),
      onPressed: () {
        setState(() {
          _sms = true;
        });
      },
    );
  }

  Widget textoDigitarSms() {
    return Text('Digitar o Código');
  }

  Future<void> _testVerifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential authCredential) {
      print('##### $authCredential #####');
      _auth.signInWithCredential(authCredential).then((_) {
        loginComFirebaseUser(_);
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      excessaoAuth = authException;
      setState(() {
        carregando = false;
      });
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
        print(authException.message);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(authException.message),
        ));
      }
      print(excessaoAuth.message);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        // carregando = false;
        this._verificationId = verificationId;
      });
      print(verificationId);
      print(forceResendingToken);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      setState(() {
        carregando = false;
      });
      print(verificationId);
      this._verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
      detectaEmulador();
    };

    setState(() {
      carregando = true;
    });
    await _auth.verifyPhoneNumber(
      phoneNumber: telefoneFormatado(),
      timeout: const Duration(seconds: 120),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
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

  void cancelaSms() {
    _sms = false;
    _smsCodeController.text = '';
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

  void loginComFirebaseUser(FirebaseUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (carregando) {
    Usuario usuario = Usuario.buscaPorTelefone(user.phoneNumber);
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
    Navigator.pushNamedAndRemoveUntil(context, Paginas.INICIAL, (r) => false);
    // }
  }

  String telefoneFormatado() {
    return telefoneController.text
        .replaceAll(" ", "")
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("-", "");
  }
}
