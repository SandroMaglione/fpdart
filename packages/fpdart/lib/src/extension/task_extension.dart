import '../either.dart';
import '../option.dart';
import '../task.dart';
import '../task_either.dart';
import '../task_option.dart';

extension CompositionOptionExtension<T> on Task<Option<T>> {
  TaskOption<T> toCompositionTaskOption() => TaskOption.fromComposition(this);
}

extension CompositionEitherExtension<L, R> on Task<Either<L, R>> {
  TaskEither<L, R> toCompositionTaskEither() => TaskEither.fromComposition(this);
}
