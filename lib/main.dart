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
  
  int notesNumber = 0;  //temporary
  int noteNum = 0;  //temporary


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200, 
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: notesNumber,
                  itemBuilder: (BuildContext ctx, index) {
                    // return Container(
                    //   alignment: Alignment.center,
                    //   decoration: BoxDecoration(
                    //     gradient: const LinearGradient(colors: [Color.fromARGB(255, 172, 218, 119), Colors.lightGreen]),
                    //       //color: Colors.green[200],
                    //       borderRadius: BorderRadius.circular(15)),
                    //   child: Text("#$noteNum"),
                    // );
                    return Card(

                    );
                  }
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: FloatingActionButton(
                        backgroundColor: Colors.green,
                        onPressed: () {
                            setState(() {
                          notesNumber++;
                          noteNum++;
                          });
                        },
                        child: const Icon(Icons.plus_one),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      )
    );
  }
}

class EditorPage extends StatelessWidget
{
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Editor Page");
  }
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
