import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'isolate_control.dart';

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
            WorkerGrid(
              isoTable: isoTable,
            )
          ],
        ),
      ),
    );
  }
}

class WorkerGrid extends StatelessWidget {
  final isoTable;

  const WorkerGrid({required this.isoTable});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 800,
      child: GridView.count(
        crossAxisCount: 8,
        children: List.generate(
          64,
          (index) => Center(
            child: Container(
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('$index'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
