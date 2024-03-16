import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';

sealed class FileSystemError {
  const FileSystemError();
}

class ReadFileError extends FileSystemError {
  const ReadFileError();
}

abstract class FileSystem {
  Effect<File, FileSystemError, List<String>> readAsLines({
    Encoding encoding = utf8,
  });
}

final class FileSystemLive extends FileSystem {
  Effect<File, FileSystemError, List<String>> readAsLines({
    Encoding encoding = utf8,
  }) =>
      Effect.env<File, FileSystemError>().flatMap(
        (file) => Effect.tryCatch(
          () async => file.readAsLines(encoding: encoding),
          (error, stackTrace) => const ReadFileError(),
        ),
      );
}
