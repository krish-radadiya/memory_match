import 'dart:async';

class TimerService {
  Timer? _timer;
  int _seconds = 0;
  void Function(int seconds)? onTick;
  int get seconds => _seconds;

  void start() {
    stop();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      onTick?.call(_seconds);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    _seconds = 0;
  }

  void dispose() {
    stop();
  }
}
