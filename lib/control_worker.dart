import 'dart:isolate';

import 'dart:math';

void worker(SendPort port) async {
  final rand = Random();
  int n = 0;
  while (true) {
    if (n == 13) {
      throw Exception('unluckly number: $n');
    }

    await Future.delayed(Duration(seconds: 1));

    if (n < 97) {
      n = rand.nextInt(100);
      port.send(n);
    } else {
      // print('top 3% percent get stuck');
    }
  }
}
