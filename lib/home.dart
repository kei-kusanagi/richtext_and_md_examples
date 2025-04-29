import 'package:flutter/material.dart';
import 'package:richtext_and_md_examples/pages/flutter_quill.dart';
import 'package:richtext_and_md_examples/pages/markdown_editor_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            Card(
              color: Colors.green,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuillHomePage()),
                    );
                  },
                  child: Text('Flutter Quill'),
                ),
              ),
            ),
            Card(
              color: Colors.purple,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MarkdownEditorPage()),
                    );
                  },
                  child: Text('Markdown Editor Plus'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
