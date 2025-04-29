import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({super.key});

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  final TextEditingController _controller = TextEditingController(
    text:
        "# Hola Markdown\n\nEste es un ejemplo de **Markdown** con vista previa en tiempo real.\n\n- Elemento 1\n- Elemento 2\n\n[Enlace a Flutter](https://flutter.dev)",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor Markdown Plus"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _controller.clear();
              });
            },
            icon: Icon(Icons.cleaning_services_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MarkdownAutoPreview(
            controller: _controller,
            emojiConvert: true,
            enableToolBar: true,
            toolbarBackground: Colors.blue,
            expandableBackground: Colors.blue[100],
          ),
        ),
      ),
    );
  }
}
