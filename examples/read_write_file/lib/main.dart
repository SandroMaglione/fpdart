import 'dart:io';

import 'package:fpdart/fpdart.dart';

import 'file_system.dart';
import 'program.dart';

/**
 * Read lines from a `.txt` file using [Effect] of fpdart.
 * 
 * This application reads from two files containing english and italian sentences.
 * It then uses `zip` to join the two resulting lists together in a `List<(String, String)>`.
 */

void main() async {
  final main = program
      .flatMap(
        (list) => Effect.function(
          () {
            list.forEach(
              (e) => print(
                  '${e.index}, ${e.word}(${e.wordIndex}): ${e.english}_${e.italian}\n'),
            );
          },
        ),
      )
      .catchAll(
        (error) => Effect.function(
          () {
            print(error);
          },
        ),
      );

  await main.runFuture(
    (
      searchWords: const ['that', 'and', 'for'],
      fileSystem: FileSystemLive(),
      sourceEng: File('./assets/source_eng.txt'),
      sourceIta: File('./assets/source_ita.txt'),
    ),
  );
}
