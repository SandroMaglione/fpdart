/// Source: http://www.learnyouahaskell.com/for-a-few-monads-more
import 'package:fpdart/src/state.dart';
import 'package:fpdart/src/tuple.dart';
import 'package:fpdart/src/unit.dart';

/// [Stack] is an alias for [List<String>].
typedef Stack = List<String>;

const Stack stack = ['a', 'b', 'c'];

/// Example Without State Monad
///
/// We need to explicitly pass the state [Stack] every time we call `pop` or `push`.

Tuple2<String, Stack> pop(Stack s) =>
    Tuple2(s.last, s.sublist(0, s.length - 1));

Tuple2<Unit, Stack> push(String value, Stack s) => Tuple2(unit, [...s, value]);

/// Example Using State Monad
///
/// The global variable [Stack] is hidden using [State].

State<Stack, String> popState() =>
    State((s) => Tuple2(s.last, s.sublist(0, s.length - 1)));

State<Stack, Unit> pushState(String value) =>
    State((s) => Tuple2(unit, [...s, value]));

void main() {
  // Without State Monad
  final pop1NoState = pop(stack);
  final push1NoState = push('d', pop1NoState.second);
  final pop2NoState = pop(push1NoState.second);
  print('No State');
  print(stack);
  print('Pop');
  print(pop1NoState.second);
  print(pop1NoState.first);
  print("Push 'd'");
  print(push1NoState.second);
  print('Pop');
  print(pop2NoState.second);
  print(pop2NoState.first);

  // Using State Monad
  print('---');
  print('Using State');
  final pop1WithState = popState();
  final push1WithState = pushState('d');
  final pop2WithState = popState();
  final stackResult = pop2WithState.run(stack);
  print(stackResult);
}
