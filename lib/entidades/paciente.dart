import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/anexo.dart';
import 'package:resident/entidades/audio.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/medicamento.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/usuario.dart';
import 'package:resident/paginas/home_page.dart';
import 'package:resident/utils/ferramentas.dart';

class Paciente {
  static Paciente mostrado;
  static List<Paciente> lista = [];
  String id;
  String nome = '';
  Grupo grupo;
  DateTime entrada;
  String telefone = '';
  String urlFoto = '';
  List hda = [];
  List hd = [];
  List hp = [];
  List<Mensagem> _mensagens = [];
  List<Medicamento> _medicamentos = [];
  List<Audio> _audios = [];
  bool alta = false;

  Paciente({
    this.id,
    this.nome = '',
    this.grupo,
    this.entrada,
    this.telefone = '',
    this.alta = false,
    this.hd,
    this.hda,
    this.hp,
    this.urlFoto,
  });

  List<Mensagem> getMensagens() {
    _mensagens = Mensagem.porPaciente(this);
    return _mensagens;
  }

  List<Medicamento> getMedicamentos() {
    _medicamentos = Medicamento.porPaciente(this);
    return _medicamentos;
  }

  List<Audio> getAudios() {
    _audios = Audio.porPaciente(this);
    return _audios;
  }

  void salvar() {
    if (id == null) {
      _criar();
      return;
    }
    _alterar();
  }

  void _criar() {
    var documento = Firestore.instance.collection('pacientes').document();
    this.id = documento.documentID;
    lista.add(this);
    setData(documento);
  }

  void _alterar() {
    var documento = Firestore.instance.collection('pacientes').document(id);
    setData(documento);
  }

  void manterMensagens() {
    Firestore.instance
        .collection('mensagens')
        .where('paciente', isEqualTo: id)
        .snapshots()
        .listen((snap) {
      snap.documents.forEach((documento) {
        Mensagem mensagem = Mensagem.buscaPorId(documento.documentID);
        if (mensagem == null)
          criaMensagem(documento);
        else
          alteraMensagem(documento, mensagem);
        manterAudios();
      });
      HomePage.atualizaTela();
    });
  }

  void manterMedicamentos() {
    Firestore.instance
        .collection('medicamentos')
        .where('paciente', isEqualTo: id)
        .snapshots()
        .listen((snap) {
      snap.documents.forEach((documento) {
        Medicamento medicamento = Medicamento.buscaPorId(documento.documentID);
        if (medicamento == null)
          criaMedicamento(documento);
        else
          alteraMedicamento(documento, medicamento);
      });
      HomePage.atualizaTela();
    });
  }

  static List<Paciente> porGrupo(String grupoId) {
    List<Paciente> selecionados = [];
    lista.forEach((paciente) {
      if (paciente.grupo.id == grupoId) selecionados.add(paciente);
    });
    return selecionados;
  }

  static List<dynamic> todosIds() {
    List<dynamic> ids = [];
    lista.forEach((paciente) {
      ids.add(paciente.id);
    });
    return ids;
  }

  void setData(DocumentReference documento) {
    documento.setData({
      'nome': nome,
      'grupo': grupo.id,
      'telefone': telefone,
      'entrada': Ferramentas.dataParaMillisseconds(entrada),
      'hp': hp,
      'hda': hda,
      'hd': hd,
      'urlFoto': urlFoto,
      'alta': alta,
    });
  }

  static Paciente buscaPorId(String id) {
    if (lista == null || lista.length == 0) return null;
    return lista.firstWhere((paciente) {
      return paciente.id == id;
    }, orElse: () => null);
  }

  void manterAudios() {
    Firestore.instance
        .collection('audios')
        .where('paciente', isEqualTo: id)
        .snapshots()
        .listen((snap) {
      snap.documents.forEach((documento) {
        Audio audio = Audio.buscaPorId(documento.documentID);
        if (audio == null)
          criarAudio(documento);
        else
          alterarAudio(documento, audio);
      });
      HomePage.atualizaTela();
    });
  }

  void criarAudio(DocumentSnapshot documento) {
    Audio audio = Audio(
        id: documento.documentID,
        paciente: Paciente.buscaPorId(documento.data['descricao']),
        url: documento.data['url']);
    audio.carregar();
    Audio.lista.add(audio);
  }

  void alterarAudio(DocumentSnapshot documento, Audio audio) {
    audio.url = documento.data['url'];
    audio.paciente = Paciente.buscaPorId(documento.data['paciente']);
    audio.carregar();
  }

  void criaMensagem(DocumentSnapshot documento) {
    Mensagem.lista.add(Mensagem(
        id: documento.documentID,
        autor: Usuario.buscaPorId(documento.data['autor']),
        anexo: Anexo.buscaPorId(
          documento.data['anexo'],
        ),
        horaCriacao:
            Ferramentas.millisecondsParaData(documento.data['horaCriacao']),
        paciente: Paciente.buscaPorId(documento.data['paciente']),
        texto: documento.data['texto'],
        tipo: documento.data['tipo']));
  }

  void alteraMensagem(DocumentSnapshot documento, Mensagem mensagem) {
    mensagem.autor = Usuario.buscaPorId(documento.data['autor']);
    mensagem.anexo = Anexo.buscaPorId(
      documento.data['anexo'],
    );
    mensagem.horaCriacao =
        Ferramentas.millisecondsParaData(documento.data['horaCriacao']);
    mensagem.paciente = Paciente.buscaPorId(documento.data['paciente']);
    mensagem.texto = documento.data['texto'];
    mensagem.tipo = documento.data['tipo'];
  }

  void criaMedicamento(DocumentSnapshot documento) {
    Medicamento.lista.add(Medicamento(
        id: documento.documentID,
        descricao: documento.data['descricao'],
        horaAdministrada: Ferramentas.millisecondsParaData(
            documento.data['horaAdministrada']),
        paciente: Paciente.buscaPorId(documento.data['paciente'])));
  }

  void alteraMedicamento(DocumentSnapshot documento, Medicamento medicamento) {
    medicamento.descricao = documento.data['descricao'];
    medicamento.horaAdministrada =
        Ferramentas.millisecondsParaData(documento.data['horaAdministrada']);
    medicamento.paciente = Paciente.buscaPorId(documento.data['paciente']);
  }

  String hpString() {
    if (hp == null || hp.length == 0) return '';
    String hpStr = '';
    hp.forEach((str) {
      hpStr += str + '\n';
    });
    return hpStr;
  }

  String hdaString() {
    if (hda == null || hda.length == 0) return '';
    String hdaStr = '';
    hda.forEach((str) {
      hdaStr += str + '\n';
    });
    return hdaStr;
  }

  String hdString() {
    if (hd == null || hd.length == 0) return '';
    String hdStr = '';
    hd.forEach((str) {
      hdStr += str + '\n';
    });
    return hdStr;
  }

  void deletar() {
    getAudios().forEach((audio) {
      audio.deletar();
    });
    getMensagens().forEach((mensagem) {
      mensagem.deletar();
    });
    getMedicamentos().forEach((medicamento) {
      medicamento.deletar();
    });
    Firestore.instance.collection('pacientes').document(id).delete();
    lista.remove(this);
  }
}
