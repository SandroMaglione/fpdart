import '../either.dart';
import '../option.dart';
import '../task.dart';
import '../task_either.dart';
import '../task_option.dart';

extension CompositionOptionExtension<T> on Task<Option<T>> {
  TaskOption<T> toTaskOption() => TaskOption.fromTaskFlatten(this);
}

extension CompositionEitherExtension<L, R> on Task<Either<L, R>> {
  TaskEither<L, R> toTaskEither() => TaskEither.fromTaskFlatten(this);
}
