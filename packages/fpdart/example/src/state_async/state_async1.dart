import 'package:fpdart/fpdart.dart';

Future<int> add10(int previous) async => previous + 10;

Future<void> main() async {
  final stateAsync = StateAsync<int, Unit>(
    (state) async => (unit, await add10(state)),
  );

  final result = await stateAsync.execute(10);
  print(result);
}
