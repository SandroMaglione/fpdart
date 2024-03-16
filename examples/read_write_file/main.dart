import 'dart:io';

import 'package:fpdart/fpdart.dart';

import 'file_system.dart';

/**
 * Read lines from a `.txt` file using [Effect] of fpdart.
 * 
 * This application reads from two files containing english and italian sentences.
 * It then uses `zip` to join the two resulting lists together in a `List<(String, String)>`.
 */

/// Store words and sentence in [FoundWord] class
class FoundWord {
  final int index;
  final String word;
  final int wordIndex;
  final String english;
  final String italian;
  const FoundWord(
    this.index,
    this.word,
    this.wordIndex,
    this.english,
    this.italian,
  );
}

/// Word to search in each sentence
const searchWords = ['that', 'and', 'for'];

Iterable<FoundWord> collectFoundWords(
  Iterable<(String, String)> iterable,
) =>
    iterable.flatMapWithIndex(
      (tuple, index) => searchWords.foldLeftWithIndex<List<FoundWord>>(
        [],
        (acc, word, wordIndex) =>
            tuple.$2.toLowerCase().split(' ').contains(word)
                ? [
                    ...acc,
                    FoundWord(
                      index,
                      word,
                      wordIndex,
                      tuple.$2.replaceAll(word, '<\$>'),
                      tuple.$1,
                    ),
                  ]
                : acc,
      ),
    );

typedef Env = ({
  FileSystem fileSystem,
  File sourceIta,
  File sourceEng,
});

void main() async {
  final collectDoNotation =
      Effect<Env, FileSystemError, Iterable<FoundWord>>.gen(
    (_) async {
      final env = await _(Effect.env());

      final linesIta = await _(
        env.fileSystem.readAsLines().withEnv(
              (env) => env.sourceIta,
            ),
      );

      final linesEng = await _(
        env.fileSystem.readAsLines().withEnv(
              (env) => env.sourceEng,
            ),
      );

      final linesZip = linesIta.zip(linesEng);
      return collectFoundWords(linesZip);
    },
  );

  final task = collectDoNotation
      .flatMap(
        (list) => Effect.function(
          () {
            /// Print all the found [FoundWord]
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

  /// Run the reading process
  await task.runFuture(
    (
      fileSystem: FileSystem(),
      sourceEng: File('./assets/source_eng.txt'),
      sourceIta: File('./assets/source_ita.txt'),
    ),
  );
}
