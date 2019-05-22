import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ProxyStorage {
  static void uploadArquivo(File file, String caminhoNoServidor,
      {Function(double percentual) progresso, Function(String) aoSubir}) {
    if (!file.existsSync()) {
      // throw Exception('Arquivo $id não existe');
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    final StorageReference ref = storage.ref().child(caminhoNoServidor);
    final StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen((evento) {
      if (evento.type == StorageTaskEventType.progress && progresso != null) {
        print('bytes transferidos: ${evento.snapshot.bytesTransferred}');
        double percentual = (evento.snapshot.bytesTransferred * 100) /
            evento.snapshot.totalByteCount;
        progresso(percentual);
      }
    });
    uploadTask.onComplete.then((snap) {
      // ref.getDownloadURL();
      aoSubir(snap.totalByteCount.toString());
    });
  }

  static void upload(
      {Function(String) aoSubir,
      String caminhoLocal,
      Function(StorageTaskEvent evento, double percentual) progresso}) async {
    // if (caminhoLocal == null) caminhoLocal = await getCaminhoLocal();
    final File file = File(caminhoLocal);
    // uploadArquivo(file, progresso: progresso, aoSubir: aoSubir);
  }
}
