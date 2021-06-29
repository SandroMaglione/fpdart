enum Level {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
  nothing,
}

class LogEvent {
  final Level level;
  final dynamic message;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEvent(this.level, this.message, this.error, this.stackTrace);
}

class OutputEvent {
  final Level level;
  final List<String> lines;

  OutputEvent(this.level, this.lines);
}

abstract class LogFilter {
  bool shouldLog(LogEvent logEvent);
}

abstract class LogPrinter {
  List<String> log(LogEvent logEvent);
}

abstract class LogOutput {
  void output(OutputEvent outputEvent);
}

class Logger {
  static Level level = Level.verbose;
  bool _active = true;
  final LogFilter _filter;
  final LogPrinter _printer;
  final LogOutput _output;

  Logger(this._filter, this._printer, this._output);

  /// Log a message with [level].
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
