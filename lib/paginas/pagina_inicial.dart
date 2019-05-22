import 'package:flutter/material.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/proxy_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaInicial extends StatefulWidget {
  @override
  _PaginaInicialState createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  @override
  void initState() {
    ProxyFirestore.observarUmaVez('inicial', () {
      buscaUsuarioLogado().then((usuario) {
        Usuario.logado = usuario;
        if (usuario != null) {
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
}
