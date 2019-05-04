import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/utils/ferramentas.dart';

class Medicamento {
  static List<Medicamento> lista = [];
  static Medicamento mostrado;
  String id;
  DateTime horaAdministrada;
  String descricao;
  Paciente paciente;

  Medicamento({this.id, this.horaAdministrada, this.descricao, this.paciente});

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  void _criar() {
    var documento = Firestore.instance.collection('medicamentos').document();
    this.id = documento.documentID;
    lista.add(this);
    setData(documento);
  }

  void _alterar() {
    var documento = Firestore.instance.collection('medicamentos').document(id);
    setData(documento);
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'horaAdministrada': Ferramentas.dataParaMillisseconds(horaAdministrada),
      'descricao': descricao,
      'paciente': paciente.id
    });
  }

  static Medicamento buscaPorId(String id) {
    if (lista == null || lista.length == 0) return null;
    return lista.firstWhere((medicamento) {
      return medicamento.id == id;
    }, orElse: () => null);
  }

  static List<Medicamento> porPaciente(Paciente paciente) {
    List<Medicamento> meds = [];
    lista.forEach((medicamento) {
      if (medicamento.paciente.id == paciente.id) meds.add(medicamento);
    });
    return meds;
  }

  void deletar() {
    Firestore.instance.collection('medicamentos').document(id).delete();
    lista.remove(this);
  }

  static Medicamento deSnap(DocumentSnapshot documento) {
    return Medicamento(
        id: documento.documentID,
        descricao: documento.data['descricao'],
        horaAdministrada: Ferramentas.millisecondsParaData(
            documento.data['horaAdministrada']),
        paciente: Paciente.buscaPorId(documento.data['paciente']));
  }
}
