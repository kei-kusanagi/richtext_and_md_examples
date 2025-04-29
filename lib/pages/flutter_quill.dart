import 'dart:convert';
import 'dart:io' as io show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart' as path;

import '../utilities/read_save_file.dart';

class QuillHomePage extends StatefulWidget {
  const QuillHomePage({super.key});

  @override
  State<QuillHomePage> createState() => _QuillHomePageState();
}

class _QuillHomePageState extends State<QuillHomePage> {
  final QuillController _controller = () {
    return QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onImagePaste: (imageBytes) async {
            if (kIsWeb) {
              // Dart IO is unsupported on the web.
              return null;
            }
            // Save the image somewhere and return the image URL that will be
            // stored in the Quill Delta JSON (the document).
            final newFileName = 'image-file-${DateTime.now().toIso8601String()}.png';
            final newPath = path.join(io.Directory.systemTemp.path, newFileName);
            final file = await io.File(newPath).writeAsBytes(imageBytes, flush: true);
            return file.path;
          },
        ),
      ),
    );
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load document
    _controller.document = Document.fromJson(kQuillDefaultSample);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Quill Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final content = jsonEncode(_controller.document.toDelta().toJson());
              if (kIsWeb) {
                saveFileWeb(
                  suggestedName: 'documento_quill.json',
                  content: content,
                  mimeType: 'application/json',
                  accept: {
                    'application/json': ['.json'],
                  },
                );
              } else {
                saveToMobile("quill_doc.json", content);
              }
            },
          ),

          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: () {
              if (kIsWeb) {
                openFileWeb((content) {
                  setState(() {
                    _controller.document = Document.fromJson(jsonDecode(content));
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Archivo cargado')));
                }, ".json");
              } else {
                readFile("quill_doc.json", (content) {
                  setState(() {
                    _controller.document = Document.fromJson(jsonDecode(content));
                  });
                }, "json");
              }
            },
          ),
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
        child: Column(
          children: [
            QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                showClipboardPaste: true,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.add_alarm_rounded),
                    onPressed: () {
                      _controller.document.insert(
                        _controller.selection.extentOffset,
                        TimeStampEmbed(DateTime.now().toString()),
                      );

                      _controller.updateSelection(
                        TextSelection.collapsed(offset: _controller.selection.extentOffset + 1),
                        ChangeSource.local,
                      );
                    },
                  ),
                ],
                buttonOptions: QuillSimpleToolbarButtonOptions(
                  base: QuillToolbarBaseButtonOptions(
                    afterButtonPressed: () {
                      final isDesktop = {
                        TargetPlatform.linux,
                        TargetPlatform.windows,
                        TargetPlatform.macOS,
                      }.contains(defaultTargetPlatform);
                      if (isDesktop) {
                        _editorFocusNode.requestFocus();
                      }
                    },
                  ),
                  linkStyle: QuillToolbarLinkStyleButtonOptions(
                    validateLink: (link) {
                      // Treats all links as valid. When launching the URL,
                      // `https://` is prefixed if the link is incomplete (e.g., `google.com` → `https://google.com`)
                      // however this happens only within the editor.
                      return true;
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder: 'Start writing your notes...',
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) {
                          // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                          if (imageUrl.startsWith('assets/')) {
                            return AssetImage(imageUrl);
                          }
                          return null;
                        },
                      ),
                      videoEmbedConfig: QuillEditorVideoEmbedConfig(
                        customVideoBuilder: (videoUrl, readOnly) {
                          // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                          return null;
                        },
                      ),
                    ),
                    TimeStampEmbedBuilder(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(String value) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}

const kQuillDefaultSample = [
  {'insert': 'Flutter Quill'},
  {
    'attributes': {'header': 1},
    'insert': '\n',
  },
  {
    'insert': {
      'video':
          'https://www.youtube.com/watch?v=V4hgdKhIqtc&list=PLbhaS_83B97s78HsDTtplRTEhcFsqSqIK&index=1',
    },
  },
  {
    'insert': {
      'video':
          'https://user-images.githubusercontent.com/122956/126238875-22e42501-ad41-4266-b1d6-3f89b5e3b79b.mp4',
    },
  },
  {'insert': '\nRich text editor for Flutter'},
  {
    'attributes': {'header': 2},
    'insert': '\n',
  },
  {'insert': 'Quill component for Flutter'},
  {
    'attributes': {'header': 3},
    'insert': '\n',
  },
  {
    'attributes': {'link': 'https://bulletjournal.us/home/index.html'},
    'insert': 'Bullet Journal',
  },
  {
    'insert':
        ':\nTrack personal and group journals (ToDo, Note, Ledger) from multiple views with timely reminders',
  },
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n',
  },
  {
    'insert':
        'Share your tasks and notes with teammates, and see changes as they happen in real-time, across all devices',
  },
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'Check out what you and your teammates are working on each day'},
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': '\nSplitting bills with friends can never be easier.'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'Start creating a group and invite your friends to join.'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'Create a BuJo of Ledger type to see expense or balance summary.'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n',
  },
  {
    'insert':
        '\nAttach one or multiple labels to tasks, notes or transactions. Later you can track them just using the label(s).',
  },
  {
    'attributes': {'blockquote': true},
    'insert': '\n',
  },
  {'insert': "\nvar BuJo = 'Bullet' + 'Journal'"},
  {
    'attributes': {'code-block': true},
    'insert': '\n',
  },
  {'insert': '\nStart tracking in your browser'},
  {
    'attributes': {'indent': 1},
    'insert': '\n',
  },
  {'insert': 'Stop the timer on your phone'},
  {
    'attributes': {'indent': 1},
    'insert': '\n',
  },
  {'insert': 'All your time entries are synced'},
  {
    'attributes': {'indent': 2},
    'insert': '\n',
  },
  {'insert': 'between the phone apps'},
  {
    'attributes': {'indent': 2},
    'insert': '\n',
  },
  {'insert': 'and the website.'},
  {
    'attributes': {'indent': 3},
    'insert': '\n',
  },
  {'insert': '\n'},
  {'insert': '\nCenter Align'},
  {
    'attributes': {'align': 'center'},
    'insert': '\n',
  },
  {'insert': 'Right Align'},
  {
    'attributes': {'align': 'right'},
    'insert': '\n',
  },
  {'insert': 'Justify Align'},
  {
    'attributes': {'align': 'justify'},
    'insert': '\n',
  },
  {'insert': 'Have trouble finding things? '},
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'Just type in the search bar'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'and easily find contents'},
  {
    'attributes': {'indent': 2, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'across projects or folders.'},
  {
    'attributes': {'indent': 2, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'It matches text in your note or task.'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'Enable reminders so that you will get notified by'},
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'email'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'message on your phone'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'popup on the web site'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n',
  },
  {'insert': 'Create a BuJo serving as project or folder'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'Organize your'},
  {
    'attributes': {'indent': 1, 'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'tasks'},
  {
    'attributes': {'indent': 2, 'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'notes'},
  {
    'attributes': {'indent': 2, 'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'transactions'},
  {
    'attributes': {'indent': 2, 'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'under BuJo '},
  {
    'attributes': {'indent': 3, 'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'See them in Calendar'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'or hierarchical view'},
  {
    'attributes': {'indent': 1, 'list': 'bullet'},
    'insert': '\n',
  },
  {'insert': 'this is a check list'},
  {
    'attributes': {'list': 'checked'},
    'insert': '\n',
  },
  {'insert': 'this is a uncheck list'},
  {
    'attributes': {'list': 'unchecked'},
    'insert': '\n',
  },
  {'insert': 'Font '},
  {
    'attributes': {'font': 'sans-serif'},
    'insert': 'Sans Serif',
  },
  {'insert': ' '},
  {
    'attributes': {'font': 'serif'},
    'insert': 'Serif',
  },
  {'insert': ' '},
  {
    'attributes': {'font': 'monospace'},
    'insert': 'Monospace',
  },
  {'insert': ' Size '},
  {
    'attributes': {'size': 'small'},
    'insert': 'Small',
  },
  {'insert': ' '},
  {
    'attributes': {'size': 'large'},
    'insert': 'Large',
  },
  {'insert': ' '},
  {
    'attributes': {'size': 'huge'},
    'insert': 'Huge',
  },
  {
    'attributes': {'size': '15.0'},
    'insert': 'font size 15',
  },
  {'insert': ' '},
  {
    'attributes': {'size': '35'},
    'insert': 'font size 35',
  },
  {'insert': ' '},
  {
    'attributes': {'size': '20'},
    'insert': 'font size 20',
  },
  {
    'attributes': {'token': 'built_in'},
    'insert': ' diff',
  },
  {
    'attributes': {'token': 'operator'},
    'insert': '-match',
  },
  {
    'attributes': {'token': 'literal'},
    'insert': '-patch',
  },
  {
    'insert': {'image': 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'},
    'attributes': {'width': '230', 'style': 'display: block; margin: auto; width: 500px;'},
  },
  {'insert': '\n'},
];
