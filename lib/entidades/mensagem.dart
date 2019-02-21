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
}

abstract class TipoMensagem {
  static const String TEXTO = 'TEXTO';
  static const String AUDIO = 'AUDIO';
  static const String IMAGEM = 'IMAGEM';
  static const String LINK = 'LINK';
}
