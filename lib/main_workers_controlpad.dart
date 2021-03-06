import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'isolate_comms.dart';

int get getMemInMb => ProcessInfo.currentRss ~/ (1024 * 1024);

const WORKERS = 36;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isoTable = context.read<IsolatesTable>();
    if (isoTable.count < 1) {
      spinupIsolates(WORKERS, isoTable);
    }
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
  final IsolatesTable isoTable;

  const WorkerGrid({required this.isoTable});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 800,
      child: GridView.count(
        crossAxisCount: 8,
        children: List.generate(
          WORKERS,
          (index) => WorkerMarker(
            isoTable: isoTable,
            index: index,
          ),
        ),
      ),
    );
  }
}

class WorkerMarker extends StatelessWidget {
  final IsolatesTable isoTable;
  final int index;

  const WorkerMarker({
    Key? key,
    required this.isoTable,
    required this.index,
  }) : super(key: key);

  int get _tableIndex => index + 1;

  String _data(int index) => isoTable.getData(_tableIndex).padLeft(2, '0');

  bool _isWorking(int index) => isoTable.isWorking(_tableIndex);

  bool _alive(int index) => isoTable.isAlive(_tableIndex);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          restartIsolate(_tableIndex, isoTable);
        },
        child: Container(
          color: _getIsolateStatusColor(index),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              '${_data(index)}',
              style: TextStyle(fontFamily: 'RobotoMono'),
            ), //+1 cause we start isolate Ids at 1
          ),
        ),
      ),
    );
  }

  Color _getIsolateStatusColor(int index) {
    if (!_alive(index)) {
      return Colors.red;
    }
    if (!_isWorking(index)) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }
}
