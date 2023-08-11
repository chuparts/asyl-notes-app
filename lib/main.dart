import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:animations/animations.dart';

late Database db;
var title = "Asyl Notes";
late int noteNum;
late MaterialColor theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = await openDatabase('asyl_notes_database.db', version: 1,
      onCreate: (Database db, int version) async {
    await db.execute(
        'CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, note_text TEXT)');
  });
  List<Map> notes = await db.query("notes");
  noteNum = notes.length;
  theme = Colors.lightGreen;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: theme,
          fontFamily: 'JosefinSans',
        ),
        debugShowCheckedModeBanner: false,
        scrollBehavior: const ConstantScrollBehavior(),
        home: const MyHomePage(title: 'Asyl Notes'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: const Icon(Icons.home),
          actions: [
            PopupMenuButton<MaterialColor>(
              initialValue: Colors.green,
              onSelected: (MaterialColor color) {
                setState(() {
                  appState.changeThemeColor(color);
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MaterialColor>>[
                const PopupMenuItem<MaterialColor>(
                  value: Colors.lightGreen,
                  child: Text('Green'),
                ),
                const PopupMenuItem<MaterialColor>(
                  value: Colors.lightBlue,
                  child: Text('Blue'),
                ),
                const PopupMenuItem<MaterialColor>(
                  value: Colors.amber,
                  child: Text('Amber'),
                ),
                const PopupMenuItem<MaterialColor>(
                  value: Colors.red,
                  child: Text('Red'),
                ),
              ],
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: theme,
            child: const Icon(Icons.plus_one),
            onPressed: () async {
              int noteId =
                  await db.insert("notes", {"title": "", "note_text": ""});
              noteNum++;
              List<Note> notes = [];
              List<Map> map = await db.query("notes");
              for (Map m in map) {
                notes.add(Note(m["id"], m["title"], m["note_text"]));
              }
              Note toBeOpened = notes[noteNum - 1];
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditorPage(toBeOpened)),
                );
              });
            }),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder<List<Map>>(
            future: db.query("notes"),
            builder:
                (BuildContext context2, AsyncSnapshot<List<Map>> snapshot) {
              List<Note> notes = [];
              if (!snapshot.hasData) {
                return const Text("Loading...", style: TextStyle(fontSize: 20));
              }
              for (Map m in snapshot.data!) {
                notes.add(Note(m["id"], m["title"], m["note_text"]));
              }
              if (notes.isEmpty) {
                return const EmptyNotesPage();
              }
              return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: notes.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return OpenContainer(
                      openBuilder: (context, closeContainer) {
                        return EditorPage(notes[index]);
                      },
                      closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      closedBuilder: (context, openContainer) {
                        return InkWell(
                          onTap: () {
                            openContainer();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notes[index].title.isEmpty
                                      ? "No title"
                                      : notes[index].title,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  notes[index].text.isEmpty
                                      ? ""
                                      : notes[index].text,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
            },
          ),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  MaterialColor themecolor = Colors.lightGreen;
  void update() {
    notifyListeners();
  }
  void changeThemeColor(MaterialColor color)
  {
    theme = color;
    themecolor = color;
    notifyListeners();
  }
}

class EmptyNotesPage extends StatelessWidget {
  const EmptyNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "No notes...",
          style: TextStyle(fontSize: 20),
        ));
  }
}

class EditorPage extends StatelessWidget {
  final Note note;
  const EditorPage(this.note, {super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            appState.update();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await db.delete("notes", where: "id = ${note.id}");
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("The note was deleted.")));
              noteNum--;
              appState.update();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              maxLength: 45,
              controller: TextEditingController(text: note.title),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              decoration: const InputDecoration(
                hintText: "Title",
                border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(width: 1)),
              ),
              onChanged: (value) {
                db.update("notes", {"title": value}, where: "id = ${note.id}");
              },
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: TextField(
                maxLength: 2000,
                textAlignVertical: TextAlignVertical.top,
                expands: true,
                maxLines: null,
                controller: TextEditingController(text: note.text),
                decoration: const InputDecoration(
                    hintText: "Text", border: OutlineInputBorder()),
                onChanged: (value) {
                  db.update("notes", {"note_text": value},
                      where: "id = ${note.id}");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  int id;
  String title;
  String text;

  Note(this.id, this.title, this.text);
}

class ConstantScrollBehavior extends ScrollBehavior {
  const ConstantScrollBehavior();

  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  TargetPlatform getPlatform(BuildContext context) => TargetPlatform.macOS;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
