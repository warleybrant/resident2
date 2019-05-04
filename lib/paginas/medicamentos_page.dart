import 'package:flutter/material.dart';
import 'package:resident/entidades/medicamento.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/ferramentas.dart';
import 'package:resident/utils/paginas.dart';
import 'package:resident/utils/tela.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class MedicamentosPage extends StatefulWidget {
  @override
  _MedicamentosPageState createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  Widget popupCriacao;
  TextEditingController descController = TextEditingController(text: '');
  MaskedTextController horaAdmController =
      MaskedTextController(text: '', mask: '00/00/2000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getCorpo(),
      floatingActionButton: getBotaoCriar(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      title: getTitulo(),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          voltar();
        },
      ),
    );
  }

  Widget getTitulo() {
    return Text('Medicamentos');
  }

  Widget getCorpo() {
    List<Widget> listaWidgets = [];
    listaWidgets.add(Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 5), vertical: Tela.y(context, 1.5)),
      child: ListView(
        children: listaMedicamentos(),
      ),
    ));
    if (popupCriacao != null) {
      listaWidgets.add(Opacity(
        opacity: .6,
        child: InkWell(
          onTap: () {
            fechaPopupCriacao();
          },
          child: Container(
            color: Colors.black,
          ),
        ),
      ));
      listaWidgets.add(Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 10), vertical: Tela.y(context, 10)),
        child: popupCriacao,
      ));
    }
    return Stack(children: listaWidgets);
  }

  voltar() {
    Navigator.popUntil(context, (r) => r.settings.name == Paginas.PACIENTE);
  }

  Widget getBotaoCriar() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        setState(() {
          abrirPopupCriacao(null);
        });
      },
    );
  }

  void abrirPopupCriacao(Medicamento medicamento) {
    if (medicamento == null)
      medicamento = Medicamento(
          paciente: Paciente.mostrado, horaAdministrada: DateTime.now());
    Medicamento.mostrado = medicamento;
    descController.text = medicamento.descricao;
    horaAdmController.text = Ferramentas.formatarData(
        medicamento.horaAdministrada,
        formato: 'dd/MM/yyyy');
    popupCriacao = Card(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Tela.x(context, 1),
          vertical: Tela.y(context, 1),
        ),
        width: Tela.x(context, 80),
        height: Tela.y(context, 45),
        child: montaPopupCriacao(),
      ),
    );
  }

  Widget montaPopupCriacao() {
    return Column(
      children: <Widget>[
        Expanded(
          child: montaCorpoPopupCriacao(),
        ),
        montaLinhaBotoesPopupCriacao()
      ],
    );
  }

  Widget montaCorpoPopupCriacao() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Tela.x(context, 2), vertical: Tela.y(context, 1)),
        child: ListView(
          children: <Widget>[
            getCampoDescricaoPopupCriacao(),
            SizedBox(height: Tela.y(context, 2)),
            getCampoHoraAdministradaPopupCriacao(),
          ],
        ),
      ),
    );
  }

  Widget getCampoDescricaoPopupCriacao() {
    return TextFormField(
      controller: descController,
      decoration: getDecoracaoCampoPopupCriacao(label: 'Descrição:'),
    );
  }

  Widget getCampoHoraAdministradaPopupCriacao() {
    return TextFormField(
      controller: horaAdmController,
      decoration: getDecoracaoCampoPopupCriacao(label: 'Dt. Administrada:'),
    );
  }

  InputDecoration getDecoracaoCampoPopupCriacao({String label}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    );
  }

  Widget montaLinhaBotoesPopupCriacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        getBotaoPopupCriacaoCancelar(),
        getBotaoPopupCriacaoSalvar(),
      ],
    );
  }

  Widget getBotaoPopupCriacaoSalvar() {
    return FlatButton(
      child: Text(
        'Salvar',
        style: getEstiloBotoesPopup(cor: Colors.blue),
      ),
      onPressed: () {
        setState(() {
          Medicamento.mostrado.descricao = descController.text;
          Medicamento.mostrado.horaAdministrada =
              Ferramentas.stringParaData(horaAdmController.text);
          Medicamento.mostrado.salvar();
          popupCriacao = null;
        });
      },
    );
  }

  Widget getBotaoPopupCriacaoCancelar() {
    return FlatButton(
      child: Text(
        'Cancelar',
        style: getEstiloBotoesPopup(cor: Colors.black),
      ),
      onPressed: () {
        fechaPopupCriacao();
      },
    );
  }

  void fechaPopupCriacao() {
    setState(() {
      popupCriacao = null;
    });
  }

  TextStyle getEstiloBotoesPopup({Color cor}) {
    return TextStyle(color: cor);
  }

  List<Widget> listaMedicamentos() {
    List<Widget> linhasMedicamento = [];
    Paciente.mostrado.getMedicamentos().forEach((Medicamento medicamento) {
      linhasMedicamento.add(getLinhaMedicamento(medicamento));
    });
    return linhasMedicamento;
  }

  Widget getLinhaMedicamento(Medicamento medicamento) {
    return InkWell(
      onTap: () {
        setState(() {
          abrirPopupCriacao(medicamento);
        });
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Tela.x(context, 2), vertical: Tela.y(context, 2)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                medicamento.descricao,
                style: getEstiloCampo(),
              ),
              Text(
                Ferramentas.formatarData(medicamento.horaAdministrada,
                    formato: 'dd/MM/yyyy'),
                style: getEstiloCampo(),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle getEstiloCampo() {
    return TextStyle(color: Colors.blue, fontSize: 17);
  }
}
