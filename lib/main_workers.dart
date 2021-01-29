import 'dart:io';
import 'dart:isolate';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'fworker.dart';

int get getMemInMb => ProcessInfo.currentRss ~/ (1024 * 1024);

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => IsolatesTable(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isolates Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Isolates Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isoTable = context.watch<IsolatesTable>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Isolates: ${isoTable.count} Mem: $getMemInMb MB',
                style: TextStyle(
                  fontSize: 36,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IsoButton(
                  text: '+1',
                  color: Colors.green,
                  onPressed: () => spinupIsolates(1, isoTable),
                ),
                Container(
                  width: 36,
                ),
                IsoButton(
                  text: '+10',
                  color: Colors.lightBlue,
                  onPressed: () => spinupIsolates(10, isoTable),
                ),
                Container(
                  width: 36,
                ),
                IsoButton(
                  text: '+100',
                  color: Colors.orange,
                  onPressed: () => spinupIsolates(100, isoTable),
                ),
                Container(
                  width: 36,
                ),
                IsoButton(
                  text: '+1000',
                  color: Colors.red,
                  onPressed: () => spinupIsolates(1000, isoTable),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class IsoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  IsoButton({
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white,
        backgroundColor: color,
        textStyle: TextStyle(
          fontSize: 36,
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}

class IsolatesTable extends ChangeNotifier {
  final _isolates = <Isolate>[];

  int get count => _isolates.length;

  void add(Isolate isolate) {
    _isolates.add(isolate);
    notifyListeners();
  }

  void clearAll() {
    _isolates.clear();
    notifyListeners();
  }
}

Future<Isolate> spawn(int id) async {
  return Isolate.spawn(worker, id);
}

Future<int> spinupIsolates(int isoCount, IsolatesTable table) async {
  final timer = Stopwatch()..start();

  for (var i = 0; i < isoCount; i += 1) {
    final iso = await spawn(table.count);
    table.add(iso);
  }
  timer..stop();
  return timer.elapsedMilliseconds;
}
