import 'dart:isolate';

import 'package:flutter/material.dart';

import 'fworker.dart';

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
