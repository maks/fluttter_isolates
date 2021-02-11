void worker(int id) async {
  while (true) {
    await Future<void>.delayed(Duration(seconds: 1));
  }
}
