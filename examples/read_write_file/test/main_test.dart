import 'dart:convert';
import 'dart:io';

import 'package:fpdart/src/effect.dart';
import 'package:fpdart_read_write_file/file_system.dart';
import 'package:fpdart_read_write_file/program.dart';
import 'package:test/test.dart';

final class FileSystemTest extends FileSystem {
  @override
  Effect<File, FileSystemError, List<String>> readAsLines(
          {Encoding encoding = utf8}) =>
      Effect.succeed(
        ["a sentence here"],
      );
}

void main() {
  test('program', () async {
    final result = await program.runFuture(
      (
        searchWords: const ['sentence'],
        fileSystem: FileSystemTest(),
        sourceEng: File(''),
        sourceIta: File(''),
      ),
    );

    expect(
      result.map((e) => e.english).toList(),
      ['a <\$> here'],
    );
  });
}
