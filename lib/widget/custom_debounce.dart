import 'dart:async';

class CustomDebounce {
  Duration delay;
  Timer? _timer;

  CustomDebounce(
      this.delay,
      );

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}