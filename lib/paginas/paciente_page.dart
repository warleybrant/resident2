import 'package:flutter/material.dart';
import 'package:resident/componentes/bubble.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/tela.dart';

class PacientePage extends StatefulWidget {
  final PageController pagina;

  PacientePage(this.pagina);

  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  PacientePageEstado estado = PacientePageEstado.PARADO;
  TextEditingController barraTexto = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Paciente.mostrado.nome),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Paciente.mostrado = null;
              widget.pagina.jumpToPage(Paginas.PACIENTES);
            }),
      ),
      endDrawer: Drawer(),
      body: corpo(),
    );
  }

  Widget corpo() {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Container(
          height: Tela.y(context, 90),
          color: Colors.teal,
          child: mensagensWidget(),
        ),
        Positioned(
          bottom: Tela.y(context, 1),
          left: Tela.x(context, 2.5),
          child: barraEscrita(),
        )
      ],
    );
  }

  Widget mensagensWidget() {
    return ListView(
      shrinkWrap: true,
      children: listaMensagensBubble(),
    );
  }

  List<Widget> listaMensagensBubble() {
    List<Bubble> bubbles = [];
    Paciente.mostrado.mensagens.forEach((mensagem) {
      String hora = Ferramentas.formatarData(mensagem.horaCriacao);
      bubbles.add(Bubble(
        isMe: mensagem.autor.id == Usuario.logado.id,
        message: mensagem.texto,
        delivered: true,
        time: hora,
      ));
    });
    return bubbles;
  }

  Widget barraEscrita() {
    var lista = [corpoBarra()];
    if (estado == PacientePageEstado.PARADO) {
      lista.add(SizedBox(
        width: Tela.x(context, 2),
      ));
      lista.add(botaoGravarAudio());
    } else if (estado == PacientePageEstado.ESCREVENDO) {
      lista.add(SizedBox(
        width: Tela.x(context, 2),
      ));
      lista.add(botaoEnviarMensagem());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: lista,
    );
  }

  Widget corpoBarra() {
    double largura = estado == PacientePageEstado.GRAVANDO_AUDIO ? 80 : 85;
    return Material(
      color: Colors.white,
      shape: StadiumBorder(),
      child: Container(
        width: Tela.x(context, largura),
        height: Tela.y(context, 5),
        child: Padding(
          padding: EdgeInsets.only(left: 15),
          child: corpoBarraInterno(),
        ),
      ),
    );
  }

  Widget corpoBarraInterno() {
    List<Widget> componentes = [];
    if (estado == PacientePageEstado.PARADO) {
      componentes.add(input());
      componentes.add(botaoAnexar());
      componentes.add(botaoTirarFoto());
    } else if (estado == PacientePageEstado.ESCREVENDO ||
        estado == PacientePageEstado.GRAVANDO_AUDIO) {
      componentes.add(input());
      componentes.add(botaoTirarFoto());
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: componentes,
    );
  }

  Widget input() {
    return Flexible(
      child: TextField(
        controller: barraTexto,
        onChanged: (_) {
          setState(() {
            estado = _.isEmpty
                ? PacientePageEstado.PARADO
                : PacientePageEstado.ESCREVENDO;
          });
        },
        decoration:
            InputDecoration(border: InputBorder.none, hintText: 'Digite aqui'),
      ),
    );
  }

  Widget botaoEnviarMensagem() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.arrow_forward),
      onPressed: () {
        Mensagem mensagem = Mensagem(
          texto: barraTexto.text,
          paciente: Paciente.mostrado,
        );
        mensagem.salvar();
        setState(() {
          barraTexto.text = '';
          estado = PacientePageEstado.PARADO;
        });
      },
    );
  }

  Widget botaoAnexar() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.attach_file),
      onPressed: () {},
    );
  }

  Widget botaoTirarFoto() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.camera_alt),
      onPressed: () {},
    );
  }

  Widget botaoGravarAudio() {
    Widget icone = estado == PacientePageEstado.GRAVANDO_AUDIO
        ? Icon(
            Icons.mic,
            size: 50,
          )
        : Icon(Icons.mic);
    return GestureDetector(
      onLongPress: () {
        setState(() {
          estado = PacientePageEstado.GRAVANDO_AUDIO;
        });
      },
      onLongPressUp: () {
        setState(() {
          estado = PacientePageEstado.PARADO;
        });
      },
      child: icone,
    );
  }
}

enum PacientePageEstado {
  PARADO,
  ESCREVENDO,
  GRAVANDO_AUDIO,
}
