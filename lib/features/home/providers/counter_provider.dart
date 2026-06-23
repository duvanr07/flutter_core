import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;

  void decrement() {
    if (state > 0) {
      state--;
    }
  }

  void reset() => state = 0;
}
