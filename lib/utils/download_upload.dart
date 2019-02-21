//import 'package:http/http.dart' as http;
//import 'package:resident/imports.dart';
//
//class DownloadUpload {
//  static String imagesPath;
//  static String tempDirPath;
//
//  static Future<Null> carregarPaths() async {
//    tempDirPath = (await getTemporaryDirectory()).path;
//    Directory tempDir = Directory(tempDirPath);
//    tempDir.listSync(recursive: true).forEach((_) {
//      String p = _.path;
//      if (p.endsWith('flutter_assets/images')) {
//        imagesPath = p;
//      }
//    });
//  }
//
//  static Future<StorageTaskSnapshot> upload(
//      String colecao, String nome, String extensao,
//      {StorageMetadata metaData,
//      String nomeNoBucket,
//      File salvarInternamente}) async {
//    Directory tempDir = await getTemporaryDirectory();
//    String nomeCompleto = '$nome.$extensao';
//    final File file = File('${tempDir.path}/$nomeCompleto');
//    if (salvarInternamente != null) {
//      if (file.existsSync()) {
//        file.deleteSync();
//      }
//      file.createSync();
//      file.writeAsBytesSync(salvarInternamente.readAsBytesSync());
//    }
//    if (!file.existsSync()) {
//      throw Exception('Arquivo $nome não existe');
//    }
//    if (nomeNoBucket != null) {
//      nomeCompleto = '$nomeNoBucket.$extensao';
//    }
//    FirebaseStorage storage = FirebaseStorage.instance;
//    final StorageReference ref =
//        storage.ref().child(colecao).child('$nomeCompleto');
//    final StorageUploadTask uploadTask = ref.putFile(
//      file,
//      metaData,
//    );
//    return uploadTask.onComplete;
//  }
//
//  static Future<File> download(String colecao, String nome) async {
//    final Directory tempDir = await getTemporaryDirectory();
//    final File arquivo = new File('${tempDir.path}/$nome');
//    if (arquivo.existsSync()) {
//      return arquivo;
//    }
//    arquivo.createSync();
//    var ref = FirebaseStorage.instance.ref().child(colecao).child(nome);
//    final url = await ref.getDownloadURL();
//    final http.Response downloadData = await http.get(url).catchError((erro) {
//      print(erro);
//      return null;
//    });
//    arquivo.writeAsBytesSync(downloadData.bodyBytes);
//    return arquivo;
//  }
//
//  static Future<String> tempDir() async {
//    return (await getTemporaryDirectory()).path;
//  }
//}
