import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resident/paginas/contatos.dart';
import 'package:resident/paginas/exames_page.dart';
import 'package:resident/paginas/grupo_page_config.dart';
import 'package:resident/paginas/grupos_page.dart';
import 'package:resident/paginas/hd_page.dart';
import 'package:resident/paginas/hda_page.dart';
import 'package:resident/paginas/hp_page.dart';
import 'package:resident/paginas/intercorrencias_page.dart';
import 'package:resident/paginas/login.dart';
import 'package:resident/paginas/medicamentos_page.dart';
import 'package:resident/paginas/paciente_config.dart';
import 'package:resident/paginas/paciente_page.dart';
import 'package:resident/paginas/pacientes_page.dart';
import 'package:resident/paginas/pagina_inicial.dart';
import 'package:resident/paginas/perfil_page.dart';
import 'package:resident/utils/cores.dart';
import 'package:resident/utils/download_upload.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // DownloadUpload.carregarPaths().then((_) {});
    Firestore.instance.settings(persistenceEnabled: false);
    Ferramentas.init();
    final ThemeData base = ThemeData.light();
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

        scaffoldBackgroundColor: /*Color(Cores.CARD_BACKGROUND)*/ Colors
            .teal[50],
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
        Paginas.MEDICAMENTOS: (context) => MedicamentosPage(),
        Paginas.INTERCORRENCIAS: (context) => IntercorrenciasPage(),
      },
    );
  }
}
