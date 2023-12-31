import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

late Database db;

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false; //disabling HTTP requests
  WidgetsFlutterBinding.ensureInitialized();
  db = await openDatabase('asyl_notes_database.db', version: 1,
      onCreate: (Database db, int version) async {
    await db.execute(
        'CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, note_text TEXT)');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asyl Notes',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        fontFamily: 'JosefinSans',
      ),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const ConstantScrollBehavior(),
      home: const MyHomePage(title: 'Asyl Notes'),
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
  int currentNoteId = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: currentNoteId < 0
              ? const Icon(Icons.home) //TODO: Create logo and add here
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    currentNoteId = -1;
                  }),
                ),
          actions: [
            currentNoteId < 0
                ? const SizedBox()
                : IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await db.delete("notes", where: "id = $currentNoteId");
                      setState(() {
                        currentNoteId = -1;
                      });
                    },
                  ),
          ],
        ),
        floatingActionButton: currentNoteId >= 0
            ? null
            : FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () async {
                  int noteId =
                      await db.insert("notes", {"title": "", "note_text": ""});
                  setState(() {
                    currentNoteId = noteId;
                  });
                },
                child: const Icon(Icons.plus_one),
              ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder<List<Map>>(
            future: db.query("notes"),
            builder:
                (BuildContext context2, AsyncSnapshot<List<Map>> snapshot) {
              List<Note> notes = [];
              if (!snapshot.hasData) {
                return Text("Loading...");
              }
              for (Map m in snapshot.data!) {
                notes.add(Note(m["id"], m["title"], m["note_text"]));
              }
              if (notes.isEmpty) {
                return EmptyNotesPage();
              }
              if (currentNoteId < 0) {
                return NoteListPage(
                    noteList: notes,
                    onNoteSelected: (index) => setState(() {
                          currentNoteId = notes[index].id;
                        }));
              } else {
                for (Note n in notes) {
                  if (n.id == currentNoteId) {
                    return EditorPage(n);
                  }
                }
                return Text("Note not found");
              }
            },
          ),
        ));
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

class NoteListPage extends StatelessWidget {
  const NoteListPage(
      {super.key, required this.noteList, required this.onNoteSelected});

  final List<Note> noteList;
  final Function(int) onNoteSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: noteList.length,
        itemBuilder: (BuildContext ctx, index) {
          return OpenContainer(
            openBuilder: (context, closedContainer) {return EditorPage(noteList[index]);},
            closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
            closedBuilder: (context, openContainer){return InkWell(
              onTap: () {
                //onNoteSelected.call(index);
                openContainer();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noteList[index].title.isEmpty
                          ? "No title"
                          : noteList[index].title,
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      noteList[index].text.isEmpty
                          ? ""
                          : noteList[index].text,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black38),
                    ),
                  ],
                ),
              ),
            );},
          );
        });
  }
}

class EditorPage extends StatelessWidget {
  final Note note;
  const EditorPage(this.note, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          maxLength: 45,
          controller: TextEditingController(text: note.title),
          decoration: const InputDecoration(
              hintText: "Title", border: OutlineInputBorder()),
          onChanged: (value) {
            db.update("notes", {"title": value}, where: "id = ${note.id}");
          },
          //TODO: create thicker border and bold text
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
