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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // La columna principal contiene las dos tarjetas con Expanded para que tengan la misma altura.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tarjeta verde
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuillHomePage()),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.green,
                      elevation: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Flutter Quill', style: Theme.of(context).textTheme.titleLarge),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '- Inline'
                                  '\nBackground Color'
                                  '\nBold'
                                  '\nColor'
                                  '\nFont'
                                  '\nInline Code'
                                  '\nItalic'
                                  '\nLink'
                                  '\nSize'
                                  '\nStrikethrough'
                                  '\nSuperscript/Subscript'
                                  '\nUnderline',
                                ),
                                Text(
                                  '- Block'
                                  '\nBlockquote'
                                  '\nHeader'
                                  '\nIndent'
                                  '\nList'
                                  '\nText Alignment'
                                  '\nText Direction'
                                  '\nCode Block'
                                  '\n- Embeds'
                                  '\nFormula'
                                  '\nImage'
                                  '\nVideo',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tarjeta púrpura
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MarkdownEditorPage()),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,

                  height: MediaQuery.of(context).size.height * 0.3,
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.deepPurple,
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Markdown Editor Plus',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '- Features '
                              '\nConvert to Bold, Italic, Strikethrough'
                              '\nConvert to Code, Quote, Links'
                              '\nConvert to Heading (H1, H2, H3).'
                              '\nConvert to unorder list and checkbox list'
                              '\nSupport multiline convert'
                              '\nSupport auto convert emoji',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
