import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:simple_permissions/simple_permissions.dart';
// import 'package:flutter/services.dart';

class PaginaInicial extends StatefulWidget {
  @override
  _PaginaInicialState createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  bool permCamera,
      permLer,
      permEscrever,
      permLerContatos,
      permGravarAudio,
      permGaleria,
      permLerSms;

  @override
  void initState() {
    // controlaPermissoes();
    controlaNotificacoes();
    ProxyFirestore.observarUmaVez('inicial', () {
      buscaUsuarioLogado().then((usuario) {
        Usuario.logado = usuario;
        if (usuario != null) {
          atualizaToken();
          ProxyFirestore.manterGrupos();
          ProxyFirestore.manterPacientes();

          if (usuario.camposPreenchidos()) {
            Navigator.pushNamedAndRemoveUntil(
                context, Paginas.GRUPOS, (r) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, Paginas.PERFIL, (r) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, Paginas.LOGIN, (r) => false);
        }
      });
    });
    ProxyFirestore.manterUsuarios();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.primaries[8],
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<Usuario> buscaUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usuarioMemoria = prefs.getString('usuarioLogado');
    Usuario usuario;
    if (usuarioMemoria != null && usuarioMemoria.isNotEmpty) {
      usuario = Usuario.buscaPorId(usuarioMemoria);
    }
    return usuario;
  }

  void controlaNotificacoes() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    if (Usuario.logado != null) {
      atualizaToken();
    }
  }

  void atualizaToken() {
    _firebaseMessaging.getToken().then((token) {
      print('O TOKEN: $token');
      Usuario.logado.token = token;
      Usuario.logado.salvar();
    });
  }

  // Future<Null> carregaPermissoes() async {
  //   permCamera = await SimplePermissions.checkPermission(Permission.Camera);
  //   permLer =
  //       await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
  //   permEscrever = await SimplePermissions.checkPermission(
  //       Permission.WriteExternalStorage);
  //   permLerContatos =
  //       await SimplePermissions.checkPermission(Permission.ReadContacts);
  //   permGravarAudio =
  //       await SimplePermissions.checkPermission(Permission.RecordAudio);
  //   permGaleria =
  //       await SimplePermissions.checkPermission(Permission.PhotoLibrary);
  //   permLerSms = await SimplePermissions.checkPermission(Permission.ReadSms);
  // }

  // void controlaPermissoes() {
  //   carregaPermissoes().then((_) async {
  //     if (!permCamera)
  //       await SimplePermissions.requestPermission(Permission.Camera);
  //     if (!permLer)
  //       await SimplePermissions.requestPermission(
  //           Permission.ReadExternalStorage);
  //     if (!permEscrever)
  //       await SimplePermissions.requestPermission(
  //           Permission.WriteExternalStorage);
  //     if (!permLerContatos)
  //       await SimplePermissions.requestPermission(Permission.ReadContacts);
  //     if (!permGravarAudio)
  //       await SimplePermissions.requestPermission(Permission.RecordAudio);
  //     if (!permGaleria)
  //       await SimplePermissions.requestPermission(Permission.PhotoLibrary);
  //     if (!permLerSms)
  //       await SimplePermissions.requestPermission(Permission.ReadSms);
  //     carregaPermissoes().then((_) {
  //       bool perm = permCamera &&
  //           permLer &&
  //           permEscrever &&
  //           permLerContatos &&
  //           permGravarAudio &&
  //           permGaleria &&
  //           permLerSms;
  //       if (!perm) {
  //         print('Não aceitou tudo');
  //       }
  //     });
  //   });
  // }
}
