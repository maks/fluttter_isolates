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
    printMemUsage();
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
            Text(
              'Isolates: ${isoTable.count} Mem: $getMemInMb MB',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => spinupIsolates(1, isoTable),
        tooltip: 'Increment',
        child: Icon(Icons.add),
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

// ref: https://github.com/dart-lang/sdk/commit/9ce608e89d6b68d84f529fd9dab18f2bc61f5a8e
void printMemUsage() {
  final currentRss = ProcessInfo.currentRss;
  final maxRss = ProcessInfo.maxRss;
  print('RSS current:$currentRss max:$maxRss');
}

Future<Isolate> spawn(int id) async {
  return Isolate.spawn(worker, id);
}

Future<int> spinupIsolates(int isoCount, IsolatesTable table) async {
  print('starting up isolates $isoCount...');
  final timer = Stopwatch()..start();

  for (var i = 0; i < isoCount; i += 1) {
    final iso = await spawn(table.count);
    table.add(iso);
  }
  timer..stop();
  print(
      'now have isoCount isolates in ${timer.elapsedMilliseconds}ms [${table.count}]');
  printMemUsage();
  return timer.elapsedMilliseconds;
}
