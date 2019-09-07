import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Ferramentas {
  static Map<String, File> arquivosCarregados = {};
  static Map<String, Uint8List> memoriaCarregada = {};
  static Directory appDir;
  static SharedPreferences prefs;

  static void init() async {
    appDir = await getApplicationDocumentsDirectory();
    prefs = await SharedPreferences.getInstance();
    _carregarArquivosNaMemoria();
  }

  static DateTime millisecondsParaData(int dataInt) {
    if (dataInt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(dataInt);
  }

  static formatarData(DateTime horaCriacao, {String formato}) {
    if (horaCriacao == null) return '';
    if (formato == null) formato = 'HH:mm';
    return DateFormat(formato).format(horaCriacao);
  }

  static int dataParaMillisseconds(DateTime data) {
    if (data == null) return -1;
    return data.millisecondsSinceEpoch;
  }

  static String soNumeros(String str) {
    return str.replaceAll(new RegExp(r'[^\d]'), '');
  }

  static DateTime stringParaData(String text) {
    try {
      return DateFormat('dd/MM/yyyy').parse(text);
    } catch (e) {
      return null;
    }
  }

  static Widget barreiraModal(Function aoTocar, {double porcentagem}) {
    return InkWell(
      onTap: aoTocar,
      child: Opacity(
        opacity: 0.7,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Card(
              child: CircularProgressIndicator(
                value: porcentagem,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget loading({@required aoTocar}) {
    return Opacity(
      opacity: 0.7,
      child: InkWell(
        onTap: () {
          aoTocar();
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: Card(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  static String getNomeDoArquivo(String url) {
    String base =
        'https://firebasestorage.googleapis.com/v0/b/resident-cadu.appspot.com/o/';
    String path = url.replaceAll(base, '');
    var pedacos = path.split('?');
    path = pedacos[0];
    path = path.replaceAll('%2F', '+_+');
    return path;
  }

  static File carregaArquivo(String url) {
    //Obtém nome do arquivo
    String nomeArquivo = getNomeDoArquivo(url);
    //Verifica se já está no mapping (na memória)
    if (arquivosCarregados.containsKey(nomeArquivo))
      return arquivosCarregados[nomeArquivo];
    //Verifica se existe gravado
    String caminhoDoArquivo = getCaminhoDoArquivo(url);
    File f = new File(caminhoDoArquivo);
    if (f.existsSync() && f.lengthSync() > 0) return f;
    return null;
  }

  static String getCaminhoDoArquivo(String url) {
    Directory diretorio = appDir;
    String nomeArquivo = getNomeDoArquivo(url);
    return '${diretorio.path}/$nomeArquivo';
  }

  static void baixarArquivo(String url, {Function(File) aoBaixar}) async {
    String nomeArquivo = getNomeDoArquivo(url);
    String caminho = getCaminhoDoArquivo(url);
    http.get(url).catchError((erro) {
      print(erro);
    }).then((_) {
      if (_ != null) {
        File arquivo = new File(caminho);
        if (!arquivo.existsSync()) {
          arquivo.createSync(recursive: true);
        }
        arquivo.writeAsBytesSync(_.bodyBytes);
        arquivosCarregados.putIfAbsent(nomeArquivo, () => arquivo);
        if (aoBaixar != null) aoBaixar(arquivo);
      }
    });
  }

  static void salvarUrl(String url) async {
    //Lê urls das preferencias
    List<String> urls = prefs.getStringList('arquivos');
    //Verifica se url já está lá, se não adiciona
    if (urls == null) urls = <String>[];
    if (!urls.contains(url)) {
      urls.add(url);
      prefs.setStringList('arquivos', urls);
    }
  }

  static void _carregarArquivosNaMemoria() {
    appDir.list().listen((data) {
      if (FileSystemEntity.isFileSync(data.path)) {
        arquivosCarregados.putIfAbsent(
            data.path.split('/').last, () => data as File);
        print(arquivosCarregados.length);
      }
    });
    //Lê a urls já salvas
    List<String> urls = prefs.getStringList('arquivos');
    if (urls == null) urls = <String>[];
    //Itera pelas urls chamando o carregar arquivo
    urls.forEach((url) {
      File arquivo = carregaArquivo(url);
      String nomeArquivo = getNomeDoArquivo(url);
      if (arquivo != null)
        arquivosCarregados.putIfAbsent(nomeArquivo, () => arquivo);
      else {
        baixarArquivo(url, aoBaixar: (arq) {
          arquivosCarregados.putIfAbsent(nomeArquivo, () => arquivo);
        });
      }
    });
  }

  static File arquivoDeBytes(String caminhoArquivo, Uint8List bytes) {
    File f = File(caminhoArquivo);
    if (f.existsSync()) {
      f.deleteSync(recursive: true);
    }
    f.createSync(recursive: true);
    f.writeAsBytesSync(bytes);
    return f;
  }

  static salvarArquivoAsync(String chave,
      {@required Function(StorageReference, String, File) aoUpload,
      Function(double) percentual,
      Function(int) falhou,
      File arquivo,
      Uint8List bytes}) {
    String nome = getNomeDoArquivo(chave);
    String local = appDir.path;
    String caminho = '$local/$nome';
    if (arquivo == null) {
      arquivo = arquivoDeBytes(caminho, bytes);
    }
    StorageReference ref = FirebaseStorage.instance.ref().child(chave);
    ref.putFile(arquivo).events.listen((data) {
      int tamanhoTotal = data.snapshot.totalByteCount;
      int bytesTransferidos = data.snapshot.bytesTransferred;
      double porcentagem = ((bytesTransferidos * 100) / tamanhoTotal);
      if (data.type == StorageTaskEventType.success) {
        File f = new File(caminho);
        if (f.existsSync()) {
          f.deleteSync(recursive: true);
        }
        f.createSync(recursive: true);
        f.writeAsBytesSync(arquivo.readAsBytesSync());

        if (aoUpload != null) {
          ref.getDownloadURL().then((url) {
            aoUpload(ref, url, f);
          });
        }
      } else if (data.type == StorageTaskEventType.failure) {
        if (falhou != null) {
          falhou(data.snapshot.error);
        }
      } else {
        if (percentual != null) {
          percentual(porcentagem);
        }
      }
    });
  }

  static carregaArquivoAsync(String chave, Function(Uint8List) aoBaixar) {
    String nome = getNomeDoArquivo(chave);
    String local = appDir.path;
    String caminho = '$local/$nome';
    if (memoriaCarregada.containsKey(caminho)) {
      aoBaixar(memoriaCarregada[caminho]);
      return;
    }
    File f = File(caminho);
    if (f.existsSync() && f.lengthSync() > 0) {
      memoriaCarregada.putIfAbsent(caminho, () => f.readAsBytesSync());
      aoBaixar(memoriaCarregada[caminho]);
      return;
    }
    StorageReference ref = FirebaseStorage.instance.ref().child(chave);
    int ti = DateTime.now().millisecondsSinceEpoch;
    print('começou a baixar');
    ref.getData(16384000).catchError((_) {
      print('problema ao baixar');
    }).then((Uint8List bytes) {
      if (bytes != null && bytes.length > 0) {
        int tf = DateTime.now().millisecondsSinceEpoch;
        int td = tf - ti;
        print('terminou de baixar. Gastou $td millisegundos');
        if (!f.existsSync()) {
          f.createSync(recursive: true);
        }
        if (f.lengthSync() == 0) {
          f.writeAsBytesSync(bytes);
        }
        memoriaCarregada.putIfAbsent(caminho, () => f.readAsBytesSync());
        aoBaixar(memoriaCarregada[caminho]);
      }
    });
  }

  String montaNomeArquivo(String nomeBruto) {
    return nomeBruto.replaceAll('/', '__');
  }

  static Uint8List buscarDaMemoria(String urlFoto) {
    if (urlFoto == null) return null;
    if (memoriaCarregada.containsKey(urlFoto)) return memoriaCarregada[urlFoto];
    return null;
  }
}
