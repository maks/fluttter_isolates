import 'dart:isolate';

import 'dart:math';

void worker(SendPort port) async {
  final rand = Random();
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    port.send(rand.nextInt(100));
  }
}
