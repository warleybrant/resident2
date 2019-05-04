import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/recurso_midia.dart';
import 'package:resident/utils/ferramentas.dart';

class Exame {
  static Map<String, List<Exame>> listagem = Map();
  static Exame mostrado;
  String id;
  String descricao;
  DateTime data;
  Paciente paciente;
  String recursoId;

  Exame({this.id, this.descricao, this.data, this.paciente, this.recursoId});

  getRecurso() {
    if (recursoId == null) return null;
    return RecursoMidia.buscaPorId(recursoId);
  }

  static List<Exame> getTodasAsMensagens() {
    var lista = <Exame>[];
    listagem.forEach((chave, valor) {
      lista.addAll(valor);
    });
    return lista;
  }

  static Exame buscaPorId(String documentID) {
    return getTodasAsMensagens()
        .firstWhere((exame) => exame.id == documentID, orElse: () => null);
  }

  static Exame deSnap(documento) {
    return Exame(
        id: documento.documentID,
        descricao: documento.data['descricao'],
        paciente: Paciente.buscaPorId(
          documento.data['paciente'],
        ),
        recursoId: documento.data['recurso'],
        data: Ferramentas.millisecondsParaData(
          documento.data['data'],
        ));
  }

  static List<Exame> porPaciente(Paciente paciente) {
    List<Exame> _exames = [];
    if (listagem[paciente.id] == null) return [];
    _exames.addAll(listagem[paciente.id]);
    return _exames;
  }

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  void _criar() {
    var documento = Firestore.instance.collection('exames').document();
    id = documento.documentID;
    setData(documento);
  }

  void _alterar() {
    var documento = Firestore.instance.collection('exames').document(id);
    setData(documento);
  }

  void setData(DocumentReference documento) {
    if (paciente != null && paciente.id == null)
      throw Exception('Tentando salvar um exame antes de salvar o paciente');
    documento.setData({
      'descricao': descricao,
      'paciente': paciente.id,
      'data': Ferramentas.dataParaMillisseconds(data),
      'recurso': recursoId,
    });
  }

  void deletar() {
    Firestore.instance.collection('exames').document(id).delete();
  }
}
