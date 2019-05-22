import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resident/utils/ferramentas.dart';

import '../entidades/paciente.dart';
import '../entidades/usuario.dart';
import '../entidades/recurso_midia.dart';
import '../entidades/mensagem.dart';
import '../entidades/grupo.dart';
import '../entidades/medicamento.dart';
import '../entidades/exame.dart';

class ProxyFirestore {
  static Map<String, Function> _observadores = Map();
  static Map<String, Function> _observadoresUnicos = Map();

  static void observar(String chave, Function aoAcionar) {
    _observadores[chave] = aoAcionar;
  }

  static void observarUmaVez(String chave, Function aoAcionar) {
    _observadoresUnicos[chave] = aoAcionar;
  }

  /// Mantém atualizada a lista estática dos usuários baseada nos
  /// retornos do firebase
  static void manterUsuarios() {
    Firestore.instance.collection('usuarios').snapshots().listen((snap) {
      Usuario.lista = [];
      snap.documents.forEach((documento) {
        Usuario usuario = Usuario.deSnap(documento);
        Usuario.lista.add(usuario);
      });
      if (Usuario.logado != null)
        Usuario.logado = Usuario.buscaPorId(Usuario.logado.id);
      notificaObservadores();
    });
  }

  /// Mantém atualizada a lista estática dos grupos baseada nos retornos
  /// do firebase
  static void manterGrupos() {
    Firestore.instance
        .collection('grupos')
        .where('contatos', arrayContains: Usuario.logado.id)
        .snapshots()
        .listen((snap) {
      Grupo.lista = [];
      snap.documents.forEach((documento) {
        Grupo grupo = Grupo.deSnap(documento);
        Grupo.lista.add(grupo);
      });

      manterPacientes();
      notificaObservadores();
    });
  }

  /// Mantém atualizada a lista estática dos pacientes baseada nos retornos
  /// do firebase
  static void manterPacientes() {
    Grupo.lista.forEach((grupo) {
      Paciente.listagem.putIfAbsent(grupo.id, () => <Paciente>[]);
      Firestore.instance
          .collection('pacientes')
          .where('grupo', isEqualTo: grupo.id)
          .snapshots()
          .listen((snap) {
        Paciente.listagem[grupo.id] = [];
        snap.documents.forEach((documento) {
          Paciente paciente = Paciente.deSnap(documento);
          Paciente.listagem[grupo.id].add(paciente);
        });
        Paciente.listagem[grupo.id].forEach((paciente) {
          manterRecursosMidia(paciente);
          manterMedicamentos(paciente);
          manterMensagens(paciente);
          manterExames(paciente);
        });
        notificaObservadores();
      });
    });
  }

  static void manterRecursosMidia(Paciente paciente) {
    Firestore.instance
        .collection('recursos_midia')
        .where('grupo', isEqualTo: paciente.grupo.id)
        .where('paciente', isEqualTo: paciente.id)
        .snapshots()
        .listen((snap) {
      RecursoMidia.lista = [];
      snap.documents.forEach((documento) {
        RecursoMidia recurso = RecursoMidia.deSnap(documento);
        RecursoMidia.lista.add(recurso);
      });
      notificaObservadores();
    });
  }

  static void manterMensagens(Paciente paciente) {
    Mensagem.listagem.putIfAbsent(paciente.id, () => <Mensagem>[]);
    Firestore.instance
        .collection('mensagens')
        .where('paciente', isEqualTo: paciente.id)
        // .orderBy('horaCriacao')
        .snapshots()
        .listen((snap) {
      Mensagem.listagem[paciente.id] = [];
      snap.documents.forEach((documento) {
        Mensagem mensagem = Mensagem.deSnap(documento);
        Mensagem.listagem[paciente.id].add(mensagem);
      });
      notificaObservadores();
    });
  }

  static void manterMedicamentos(Paciente paciente) {
    Firestore.instance
        .collection('medicamentos')
        .where('paciente', isEqualTo: paciente.id)
        .snapshots()
        .listen((snap) {
      Medicamento.lista = [];
      snap.documents.forEach((documento) {
        Medicamento medicamento = Medicamento.deSnap(documento);
        Medicamento.lista.add(medicamento);
      });
      notificaObservadores();
    });
  }

  static void manterExames(Paciente paciente) {
    Exame.listagem.putIfAbsent(paciente.id, () => <Exame>[]);
    Firestore.instance
        .collection('exames')
        .where('paciente', isEqualTo: paciente.id)
        .snapshots()
        .listen((snap) {
      Exame.listagem[paciente.id] = [];
      snap.documents.forEach((documento) {
        Exame exame = Exame.deSnap(documento);
        Exame.listagem[paciente.id].add(exame);
      });
      notificaObservadores();
    });
  }

  static void adicionarRecurso(DocumentSnapshot documento) {
    RecursoMidia.lista.add(RecursoMidia(
        id: documento.documentID,
        tipo: TipoRecurso.values[documento.data['tipo']],
        grupo: Grupo.buscaPorId(documento.data['grupo']),
        paciente: Paciente.buscaPorId(documento.data['paciente']),
        extensao: documento.data['extensao']));
  }

  static void alteraRecurso(DocumentSnapshot documento, RecursoMidia recurso) {
    recurso.tipo = TipoRecurso.values[documento.data['tipo']];
    recurso.grupo = Grupo.buscaPorId(documento.data['grupo']);
    recurso.paciente = Paciente.buscaPorId(documento.data['paciente']);
    recurso.extensao = documento.data['extensao'];
  }

  static void criaMensagem(DocumentSnapshot documento) {
    Mensagem.listagem[documento.data['paciente']].add(Mensagem(
        id: documento.documentID,
        autor: Usuario.buscaPorId(documento.data['autor']),
        recursoMidia: RecursoMidia.buscaPorId(
          documento.data['recursoMidia'],
        ),
        horaCriacao:
            Ferramentas.millisecondsParaData(documento.data['horaCriacao']),
        paciente: Paciente.buscaPorId(documento.data['paciente']),
        texto: documento.data['texto'],
        tipo: documento.data['tipo']));
  }

  static void alteraMensagem(DocumentSnapshot documento, Mensagem m) {
    int indice = Mensagem.listagem[m.paciente.id].indexOf(m);
    Mensagem.listagem[m.paciente.id][indice].autor =
        Usuario.buscaPorId(documento.data['autor']);
    Mensagem.listagem[m.paciente.id][indice].recursoMidia =
        RecursoMidia.buscaPorId(
      documento.data['recursoMidia'],
    );
    Mensagem.listagem[m.paciente.id][indice].horaCriacao =
        Ferramentas.millisecondsParaData(documento.data['horaCriacao']);
    Mensagem.listagem[m.paciente.id][indice].paciente =
        Paciente.buscaPorId(documento.data['paciente']);
    Mensagem.listagem[m.paciente.id][indice].texto = documento.data['texto'];
    Mensagem.listagem[m.paciente.id][indice].tipo = documento.data['tipo'];
    print('${Mensagem.listagem[m.paciente.id][indice]}');
  }

  static void criaMedicamento(DocumentSnapshot documento) {
    Medicamento.lista.add(Medicamento(
        id: documento.documentID,
        descricao: documento.data['descricao'],
        horaAdministrada: Ferramentas.millisecondsParaData(
            documento.data['horaAdministrada']),
        paciente: Paciente.buscaPorId(documento.data['paciente'])));
  }

  static void alteraMedicamento(
      DocumentSnapshot documento, Medicamento medicamento) {
    medicamento.descricao = documento.data['descricao'];
    medicamento.horaAdministrada =
        Ferramentas.millisecondsParaData(documento.data['horaAdministrada']);
    medicamento.paciente = Paciente.buscaPorId(documento.data['paciente']);
  }

  static notificaObservadores() {
    _observadores.forEach((chave, observador) {
      observador();
    });
    _observadoresUnicos.forEach((chave, valor) {
      valor();
    });
    _observadoresUnicos.clear();
  }

  /// Adiciona um usuário à lista estática de usuários baseado
  /// no retorno do firebase
  static void adicionaUsuario(DocumentSnapshot documento) {
    Usuario.lista.add(Usuario(
        id: documento.documentID,
        nome: documento.data['nome'],
        idResidente: documento.data['idResidente'],
        telefone: documento.data['telefone'],
        email: documento.data['email'],
        uid: documento.data['uid'],
        urlFoto: documento.data['urlFoto'],
        contatos: documento.data['contatos']));
  }

  /// Altera um usuário da lista estática de usuários baseado
  /// no retorno do firebase
  static void alteraUsuario(DocumentSnapshot documento, Usuario usuario) {
    usuario.nome = documento.data['nome'];
    usuario.idResidente = documento.data['idResidente'];
    usuario.telefone = documento.data['telefone'];
    usuario.uid = documento.data['uid'];
    usuario.urlFoto = documento.data['urlFoto'];
    usuario.contatos = documento.data['contatos'];
  }

  /// Altera um grupo da lista estática de grupos baseado
  /// no retorno do firebase
  static void alterarGrupo(DocumentSnapshot documento, Grupo grupo) {
    grupo.nome = documento.data['nome'];
    grupo.descricao = documento.data['descricao'];
    grupo.contatos = documento.data['contatos'];
    grupo.urlFoto = documento.data['urlFoto'];
  }

  /// Adiciona um grupo à lista estática de grupos baseado
  /// no retorno do firebase
  static void adicionarGrupo(DocumentSnapshot documento) {
    Grupo.lista.add(
      Grupo(
          id: documento.documentID,
          nome: documento.data['nome'],
          descricao: documento.data['descricao'],
          contatos: documento.data['contatos'],
          urlFoto: documento.data['urlFoto']),
    );
  }

  /// Adiciona um paciente à lista estática de pacientes baseado
  /// no retorno do firebase
  static Paciente adicionarPaciente(DocumentSnapshot documento) {
    Paciente paciente = Paciente(
      id: documento.documentID,
      nome: documento.data['nome'],
      grupo: Grupo.buscaPorId(documento.data['grupo']),
      telefone: documento.data['telefone'],
      entrada: Ferramentas.millisecondsParaData(documento.data['entrada']),
      hp: documento.data['hp'],
      hda: documento.data['hda'],
      hd: documento.data['hd'],
      alta: documento.data['alta'],
    );
    Paciente.listagem[documento.data['grupo']].add(paciente);
    return paciente;
  }

  /// Altera um paciente da lista estática de pacientes baseado
  /// no retorno do firebase
  static void alterarPaciente(DocumentSnapshot documento, Paciente paciente) {
    paciente.nome = documento.data['nome'];
    paciente.grupo = Grupo.buscaPorId(documento.data['grupo']);
    paciente.telefone = documento.data['telefone'];
    paciente.entrada =
        DateTime.fromMillisecondsSinceEpoch(documento.data['entrada']);
    paciente.hp = documento.data['hp'];
    paciente.hda = documento.data['hda'];
    paciente.hd = documento.data['hd'];
    paciente.urlFoto = documento.data['urlFoto'];
    paciente.alta = documento.data['alta'];
  }

  static void pararDeObservar(String chave) {
    _observadores.remove(chave);
  }
}
