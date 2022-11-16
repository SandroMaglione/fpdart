import 'package:fpdart/fpdart.dart';

Future<void> main() async {
  /// Create instance of [IO] from a value
  final IO<int> io = IO.of(10);

  /// Create instance of [IO] from a sync function
  final ioRun = IO(() => 10);

  /// Map [int] to [String]
  final IO<String> map = io.map((a) => '$a');

  /// Extract the value inside [IO] by running its function
  final int value = io.run();

  /// Chain another [IO] based on the value of the current [IO]
  final flatMap = io.flatMap((a) => IO.of(a + 10));
}
