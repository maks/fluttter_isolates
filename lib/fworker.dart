void worker(int id) async {
  while (true) {
    await Future.delayed(Duration(seconds: 1));
  }
}

void main(List args) {
  worker(args[0]);
}
