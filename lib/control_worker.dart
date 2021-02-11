import 'dart:isolate';

import 'dart:math';

void worker(SendPort port) async {
  final rand = Random();
  var n = 0;
  while (true) {
    if (n == 13) {
      throw Exception('unluckly number: $n');
    }
    if (n < 99) {
      n = rand.nextInt(100);
      port.send(n);
    } else {
      // print('top 1% percent get stuck');
    }

    await Future<void>.delayed(Duration(seconds: 1));
  }
}
