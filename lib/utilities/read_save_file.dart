import 'dart:io' as io;
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

/// Guarda el contenido en un archivo, compatible con Web, Móvil y Escritorio.
Future<void> saveFileWeb({
  required String suggestedName,
  required String content,
  required String mimeType,
  required Map<String, List<String>> accept, // ej: {'text/markdown': ['.md']}
}) async {
  // ¿Está disponible showSaveFilePicker?
  if (js_util.hasProperty(html.window, 'showSaveFilePicker')) {
    // Configuración del diálogo
    final pickerOpts = js_util.jsify({
      'suggestedName': suggestedName,
      'types': [
        {'description': 'Archivo de ${accept.values.first.join(", ")}', 'accept': accept},
      ],
    });

    try {
      // 1) Abrimos el diálogo y obtenemos el FileSystemFileHandle
      final fileHandle = await js_util.promiseToFuture(
        js_util.callMethod(html.window, 'showSaveFilePicker', [pickerOpts]),
      );

      // 2) Creamos un WritableStream
      final writable = await js_util.promiseToFuture(
        js_util.callMethod(fileHandle, 'createWritable', []),
      );

      // 3) Escribimos el contenido
      await js_util.promiseToFuture(js_util.callMethod(writable, 'write', [content]));

      // 4) Cerramos el stream
      await js_util.promiseToFuture(js_util.callMethod(writable, 'close', []));
    } catch (e) {
      // El usuario canceló o hubo un error
      if (kDebugMode) {
        print('Guardado cancelado o falló: $e');
      }
    }
  } else {
    // Fallback: descarga automática en Downloads
    final blob = html.Blob([content], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', suggestedName)
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}

/// Guarda el archivo en móvil y escritorio permitiendo elegir una carpeta.
Future<void> saveToMobile(String filename, String content) async {
  String? selectedPath = await FilePicker.platform.getDirectoryPath();
  if (selectedPath != null) {
    final file = io.File('$selectedPath/$filename');
    await file.writeAsString(content);
  }
}

/// Lee un archivo guardado en móvil y escritorio.
Future<void> readFile(
  String filename,
  Function(String) onFileSelected,
  String allowedExtension,
) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: [allowedExtension], // Filtra extensiones
  );

  if (result != null) {
    final file = io.File(result.files.single.path!);
    final content = await file.readAsString();
    onFileSelected(content);
  } else {
    if (kDebugMode) {
      print("Selección de archivo cancelada.");
    }
  }
}

/// Abre un selector de archivos en Web y carga su contenido.
void openFileWeb(Function(String) onFileSelected, String allowedExtension) {
  final input = html.FileUploadInputElement();
  input.accept = allowedExtension; // Filtra por extensión permitida
  input.click();

  input.onChange.listen((event) {
    final file = input.files!.first;
    if (!file.name.endsWith(allowedExtension)) {
      html.window.alert("Solo se permiten archivos del tipo $allowedExtension");
      return;
    }

    final reader = html.FileReader();
    reader.readAsText(file);
    reader.onLoadEnd.listen((_) {
      onFileSelected(reader.result as String);
    });
  });
}
