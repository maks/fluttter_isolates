# flutter_isolates


## notes

run on master but with isolate-groups disabled:
```
flutter run --dart-flags=--no-enable-isolate-groups --release lib/main_workers.dart
```

commit that added isolate groups to allowed dart flags:
https://github.com/flutter/engine/commit/c0b75ffd19e4fe6d6adf9b2b0661bda0f33a4fc4