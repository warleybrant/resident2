import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/paginas/home_page.dart';

class PacientesPage extends StatefulWidget {
  final PageController pagina;

  PacientesPage(this.pagina);

  @override
  _PacientesPageState createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Grupo.mostrado.nome}'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Grupo.mostrado = null;
              widget.pagina.jumpToPage(Paginas.GRUPOS);
            }),
      ),
      body: corpo(),
    );
  }

  Widget corpo() {
    return listaPacientes();
  }

  Widget listaPacientes() {
    if (Paciente.lista == null) return Container();
    List<Widget> pacientesCard = [];
    Paciente.porGrupo(Grupo.mostrado.id).forEach((paciente) {
      pacientesCard.add(cardPaciente(paciente));
    });
    return ListView(
      children: pacientesCard,
    );
  }

  Widget cardPaciente(Paciente paciente) {
    var foto = paciente.urlFoto != null
        ? CachedNetworkImageProvider(paciente.urlFoto, errorListener: () {})
        : null;

    Widget fotoGrupo = foto != null
        ? Container(
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: foto,
              ),
            ),
          )
        : SizedBox(
            width: 80,
            child: CircleAvatar(
              child: Icon(Icons.add_a_photo),
            ),
          );
    Widget textoGrupo = Expanded(
      child: MaterialButton(
          child: Text(paciente.nome),
          onPressed: () {
            Paciente.mostrado = paciente;
            widget.pagina.jumpToPage(Paginas.PACIENTE);
          }),
    );
    Widget configuracoesGrupo = RaisedButton(
      shape: CircleBorder(),
      color: Colors.white,
      child: Icon(Icons.build),
      onPressed: () {
        Paciente.mostrado = paciente;
        widget.pagina.jumpToPage(Paginas.PACIENTE);
      },
    );
    List<Widget> lista = [fotoGrupo, textoGrupo, configuracoesGrupo];
    return Card(
      key: Key(paciente.id),
      elevation: 5,
      child: Container(
        height: 80,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: lista,
          ),
        ),
      ),
    );
  }
}
