import 'package:resident/entidades/anexo.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';

class Mensagem {
  static List<Mensagem> lista = [];
  String id;
  String texto;
  Anexo anexo;
  DateTime horaCriacao;
  Paciente paciente;
  TipoMensagem tipo;
  Usuario autor;

  Mensagem(
      {this.id,
      this.texto,
      this.anexo,
      this.horaCriacao,
      this.paciente,
      this.tipo,
      this.autor});

  static Mensagem buscaPorId(String documentID) {
    return lista.firstWhere((mensagem) => mensagem.id == documentID,
        orElse: () => null);
  }

  static List<Mensagem> porPaciente(Paciente paciente) {
    List<Mensagem> msgs = [];
    lista.forEach((mensagem) {
      if (mensagem.paciente.id == paciente.id) msgs.add(mensagem);
    });
    return msgs;
  }
}

abstract class TipoMensagem {
  static const String TEXTO = 'TEXTO';
  static const String AUDIO = 'AUDIO';
  static const String IMAGEM = 'IMAGEM';
  static const String LINK = 'LINK';
}
