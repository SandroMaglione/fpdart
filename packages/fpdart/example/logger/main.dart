/// Convert `log` function from `logger` package
/// from Imperative to Functional code using `fpdart`
///
/// Repository: https://github.com/leisim/logger
import 'package:fpdart/fpdart.dart';

import 'logger.dart';

class Logger {
  static Level level = Level.verbose;
  bool _active = true;
  final LogFilter _filter;
  final LogPrinter _printer;
  final LogOutput _output;
  Logger(this._filter, this._printer, this._output);

  /// Imperative (not-functional) code
  ///
  /// From https://github.com/leisim/logger/blob/6832ee0f5c430321f6a74dce99338b242861161d/lib/src/logger.dart#L104
  void log(
    Level level,
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_active) {
      throw ArgumentError('Logger has already been closed.');
    } else if (error != null && error is StackTrace) {
      throw ArgumentError('Error parameter cannot take a StackTrace!');
    } else if (level == Level.nothing) {
      throw ArgumentError('Log events cannot have Level.nothing');
    }
    var logEvent = LogEvent(level, message, error, stackTrace);

    if (_filter.shouldLog(logEvent)) {
      var output = _printer.log(logEvent);

      if (output.isNotEmpty) {
        var outputEvent = OutputEvent(level, output);
        try {
          _output.output(outputEvent);
        } catch (e, s) {
          print(e);
          print(s);
        }
      }
    }
  }
}

/// Functional approach 💪
/// ----------------------------------------------------------------
/// Use [IOEither] to handle errors and avoid throwing exceptions 🔨
///
/// Use [Unit] instead of `void` to represent a function that returns nothing 🎭
IOEither<String, Unit> logFunctional({
  required Level level,
  required dynamic message,
  required dynamic error,
  StackTrace? stackTrace,

  /// Add all external dependencies as input to make the function pure 🥼
  required bool active,
  required LogFilter filter,
  required LogPrinter printer,
  required LogOutput output,
}) {
  /// Handle errors using [Either] instead of throwing errors 💥
  if (!active) {
    return IOEither.left('Logger has already been closed.');
  } else if (error != null && error is StackTrace) {
    return IOEither.left('Error parameter cannot take a StackTrace!');
  } else if (level == Level.nothing) {
    return IOEither.left('Log events cannot have Level.nothing');
  }

  /// Declare all the variables as `const` or `final` 🧱
  final logEvent = LogEvent(level, message, error, stackTrace);

  /// Make sure to handle all the cases using [Option] 🎉
  ///
  /// Use the `identity` function to return the input parameter as it is
  final shouldLogOption = Option.fromPredicate(
    filter.shouldLog(logEvent),
    identity,
  );

  /// Using [Option], you must specify both `true` and `false` cases 🌎
  return shouldLogOption.match(
    /// Simply return a [Unit] in the else case 🎁
    () => IOEither.of(unit),

    /// Use another [Option] to evaluate `printer.log`
    (_) => Option<List<String>>.fromPredicate(
      printer.log(logEvent),
      (v) => v.isNotEmpty,
    ).match(
      /// Simply return a [Unit] in the else case 🎁
      () => IOEither.of(unit),

      (lines) {
        /// All variables are `final` 🧱
        final outputEvent = OutputEvent(level, lines);
        return IOEither<String, Unit>.tryCatch(
          () {
            output.output(outputEvent);

            /// Return [Unit] 🎁
            return unit;
          },
          (e, s) {
            /// Return an error message 🔨
            ///
            /// Do not `print`, it would make the function impure! 🤯
            return 'An error occurred: $e';
          },
        );
      },
    ),
  );
}
