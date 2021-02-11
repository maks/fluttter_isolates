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

  void _replace(id, isolate) {
    _isolates[id] = IsolateRecord(isolate);
    notifyListeners();
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

Future<int> spinupIsolates(int isoCount, IsolatesTable table) async {
  final timer = Stopwatch()..start();

  for (var i = 0; i < isoCount; i++) {
    await _setupIsolate(table);
  }
  timer..stop();
  return timer.elapsedMilliseconds;
}

Future<void> restartIsolate(id, IsolatesTable table) async {
  await _setupIsolate(table, id: id);
}

Future<Isolate> _setupIsolate(IsolatesTable table, {int? id}) async {
  final port = ReceivePort();
  final _onExit = ReceivePort();
  final isolate = await _spawn(port.sendPort, _onExit.sendPort);

  late int isoId;

  if (id != null) {
    isoId = id;
    table._replace(isoId, isolate);
  } else {
    isoId = table.add(isolate);
  }

  _onExit.listen((message) {
    print('isolate $id errored out');
    table._updateIsolateData(isoId, message: message, dead: true);
  });
  isolate.addOnExitListener(_onExit.sendPort);

  port.listen((message) {
    //print('message from isolate $id: $message');
    table._updateIsolateData(isoId, message: message.toString());
  });
  return isolate;
}

Future<Isolate> _spawn(SendPort port, SendPort onExit) async {
  final isolate = await Isolate.spawn(worker, port, onExit: onExit);
  return isolate;
}
