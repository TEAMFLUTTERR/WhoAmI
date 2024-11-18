import 'dart:async';

class TimerHelper {
  static void startTimer(int seconds, Function onComplete) {
    Timer(Duration(seconds: seconds), () {
      onComplete();
    });
  }
}
