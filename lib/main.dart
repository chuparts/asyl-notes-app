import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const ConstantScrollBehavior(),
      home: const MyHomePage(title: 'Assylzhan Notes App Demo'),
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
  List<Note> noteList = [Note("loltitle", "loltext"), Note("hello", "world!")];

  int currentNoteIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            setState(() {
              noteList.add(Note("New note", "New note text"));
            });
          },
          child: const Icon(Icons.plus_one),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: currentNoteIndex < 0
              ? NoteListPage(
                  noteList: noteList,
                  onNoteSelected: (index) => setState(() {
                        currentNoteIndex = index;
                      }))
              : EditorPage(),
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
          return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: () {
                  // print("lol");
                  onNoteSelected.call(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(noteList[index].title),
                ),
              ));
        });
  }
}

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Editor Page");
  }
}

class Note {
  String title;
  String text;

  Note(this.title, this.text);
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
