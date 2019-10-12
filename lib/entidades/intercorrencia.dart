import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/entidades/grupo.dart';
import 'package:resident/entidades/mensagem.dart';
import 'package:resident/entidades/paciente.dart';
import 'package:resident/entidades/usuario.dart';

class Intercorrencia {
  String pacienteId;
  String texto;

  Intercorrencia(this.pacienteId, this.texto);

  void disparar() {
    var ref = Firestore.instance.collection('intercorrencias').document();
    ref.setData({'pacienteId': pacienteId, 'texto': texto});
    Mensagem msg = Mensagem(
        autor: Usuario.logado,
        grupo: Grupo.mostrado,
        horaCriacao: DateTime.now(),
        paciente: Paciente.mostrado,
        texto: texto,
        tipo: 'TEXTO');
    msg.salvar();
  }
}
