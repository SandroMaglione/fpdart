import 'package:fpdart/fpdart.dart';

late Future<Map<String, Object>?> example;

final taskOp = TaskOption.flatten(
  (TaskOption.fromTask(
    Task<Map<String, Object>?>(
      () => example,
    ).map(
      (ex) => Option.fromNullable(ex).toTaskOption(),
    ),
  )),
);

/// New API `toOption`: from `Map<String, Object>?` to `Option<Map<String, Object>>`
final taskOpNew = TaskOption<Map<String, Object>>(
  () async => (await example).toOption(),
);

/// Using `Option.fromNullable`, the [Future] cannot fail
final taskOpNoFail = TaskOption<Map<String, Object>>(
  () async => Option.fromNullable(await example),
);

/// Using `Option.fromNullable` when the [Future] can fail
final taskOpFail = TaskOption<Map<String, Object>?>.tryCatch(
  () => example,
).flatMap<Map<String, Object>>(
  (r) => Option.fromNullable(r).toTaskOption(),
);
