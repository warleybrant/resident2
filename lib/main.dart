import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/exame.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/medicamento.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/recurso_midia.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/contatos.dart';
import 'package:resident/paginas/exames_page.dart';
import 'package:resident/paginas/grupo_page_config.dart';
import 'package:resident/paginas/grupos_page.dart';
import 'package:resident/paginas/hd_page.dart';
import 'package:resident/paginas/hda_page.dart';
import 'package:resident/paginas/hp_page.dart';
import 'package:resident/paginas/login.dart';
import 'package:resident/paginas/medicamentos_page.dart';
import 'package:resident/paginas/paciente_config.dart';
import 'package:resident/paginas/paciente_page.dart';
import 'package:resident/paginas/pacientes_page.dart';
import 'package:resident/paginas/pagina_inicial.dart';
import 'package:resident/paginas/perfil_page.dart';
import 'package:resident/teste.dart';
import 'package:resident/utils/cores.dart';
import 'package:resident/utils/download_upload.dart';
import 'package:resident/utils/paginas.dart';

Future<void> main() async {
  Firestore.instance.settings(persistenceEnabled: true);
  DownloadUpload.carregarPaths().then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();
    Firestore.instance.settings(persistenceEnabled: true);
    return MaterialApp(
      title: 'Residente',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Color(Cores.APPBAR),
        accentColor: Color(Cores.FLOATING_BUTTON_BACKGROUND),
        iconTheme: base.iconTheme.copyWith(color: Color(0xFFE7ECEF)),
        buttonTheme: base.buttonTheme.copyWith(
          buttonColor: Colors.tealAccent,
        ),

        scaffoldBackgroundColor: /*Color(Cores.CARD_BACKGROUND)*/ Colors.teal,
//        cardColor: Color(Cores.CARD_BACKGROUND),
      ),
      home: PaginaInicial(),
      // home: Teste1(),
      routes: {
        Paginas.INICIAL: (context) => PaginaInicial(),
        Paginas.LOGIN: (context) => LoginPage(),
        Paginas.CONTATOS: (context) => ContatosPage(),
        Paginas.PERFIL: (context) => PerfilPage(),
        Paginas.GRUPOS: (context) => GruposPage(),
        Paginas.GRUPO_CONFIG: (context) => GrupoPage(),
        Paginas.PACIENTES: (context) => PacientesPage(),
        Paginas.PACIENTE: (context) => PacientePage(),
        Paginas.PACIENTE_CONFIG: (context) => PacienteConfigPage(),
        Paginas.EXAMES: (context) => ExamesPage(),
        Paginas.HD: (context) => HDPage(),
        Paginas.HDA: (context) => HDAPage(),
        Paginas.HP: (context) => HPPage(),
        Paginas.MEDICAMENTOS: (context) => MedicamentosPage()
      },
    );
  }
}
