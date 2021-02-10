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

  bool isWorking(int isolateId) => false == _isolates[isolateId]?.outOfDate;

  bool isAlive(int isolateId) => _isolates[isolateId]?.isolate != null;

  void clearAll() {
    _isolates.clear();
    notifyListeners();
  }

  void _updateIsolateData(int id, {String? message, bool dead = false}) {
    if (message != null) {
      _isolates[id]?.data = message;
      _isolates[id]?.lastUpdate = DateTime.now();
    }
    if (dead) {
      _isolates[id]?.isolate = null;
    }
    notifyListeners();
  }
}

class IsolateRecord {
  Isolate? isolate;
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
    final _onExit = ReceivePort();
    _onExit.listen((message) {
      print('isolate $id errored out');
      table._updateIsolateData(id, message: message, dead: true);
    });
    iso.addOnExitListener(_onExit.sendPort);

    port.listen((message) {
      //print('message from isolate $id: $message');
      table._updateIsolateData(id, message: message.toString());
    });
  }
  timer..stop();
  return timer.elapsedMilliseconds;
}
