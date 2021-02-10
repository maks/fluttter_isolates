import 'dart:isolate';

import 'package:flutter/material.dart';

import 'control_worker.dart';

class IsolatesTable extends ChangeNotifier {
  final _isolates = <int, IsolateRecord>{};
  var idCounter = 1;

  int get count => _isolates.length;

  int add(Isolate isolate) {
    final isoId = idCounter++;
    _isolates[isoId] = IsolateRecord(isolate);
    notifyListeners();
    return isoId;
  }

  String getData(int isolateId) => _isolates[isolateId]?.data ?? '';

  bool isAlive(int isolateId) => false == _isolates[isolateId]?.outOfDate;

  void clearAll() {
    _isolates.clear();
    notifyListeners();
  }

  void updateIsolateData(int id, String message) {
    _isolates[id]?.data = message;
    _isolates[id]?.lastUpdate = DateTime.now();
    notifyListeners();
  }
}

class IsolateRecord {
  final Isolate isolate;
  String data = '';
  DateTime? lastUpdate;

  IsolateRecord(this.isolate);
}

extension IsolateRecordMethods on IsolateRecord {
  static const maxUpdatePeriod = Duration(milliseconds: 3000);
  bool get outOfDate {
    final last = lastUpdate;
    return last != null
        ? DateTime.now().subtract(maxUpdatePeriod).isAfter(last)
        : false;
  }
}

Future<Isolate> spawn(SendPort port) async {
  final isolate = await Isolate.spawn(worker, port);
  return isolate;
}

Future<int> spinupIsolates(int isoCount, IsolatesTable table) async {
  final timer = Stopwatch()..start();

  for (var i = 0; i < isoCount; i++) {
    final port = ReceivePort();
    final iso = await spawn(port.sendPort);
    final id = table.add(iso);
    port.listen((message) {
      //print('message from isolate $id: $message');
      table.updateIsolateData(id, message.toString());
    });
  }
  timer..stop();
  return timer.elapsedMilliseconds;
}
