import 'package:fpdart/fpdart.dart';

/// You must run one [Future] after the other, no way around this...
Future<int> asyncI() {
  return Future.value(10).then((value) => value * 10);
}

/// No need of `async`, you decide when to run the [Future] ⚡
Task<int> asyncF() {
  return Task(() async => 10).map((a) => a * 10);
}

Future<void> main() async {
  /// Create instance of [Task] from a value
  final Task<int> task = Task.of(10);

  /// Create instance of [Task] from an async function
  final taskRun1 = Task(() async => 10);
  final taskRun2 = Task(() => Future.value(10));

  /// Map [int] to [String]
  final Task<String> map = task.map((a) => '$a');

  /// Extract the value inside [Task] by running its async function
  final int value = await task.run();

  /// Chain another [Task] based on the value of the current [Task]
  final flatMap = task.flatMap((a) => Task.of(a + 10));
}
