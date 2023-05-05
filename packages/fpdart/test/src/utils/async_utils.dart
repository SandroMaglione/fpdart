import 'dart:math';

abstract class AsyncUtils {
  /// Wait a random number of milliseconds between
  /// 0 and `maxMilliseconds`.
  static Future<void> waitFuture({
    /// Max number of milliseconds to wait
    int maxMilliseconds = 300,
  }) =>
      Future.delayed(
        Duration(
          milliseconds: Random().nextInt(maxMilliseconds),
        ),
      );
}
