import 'dart:io';

import 'package:fpdart/fpdart.dart';

/**
 * Read lines from a `.txt` file using [TaskEither] of fpdart.
 * 
 * This application reads from two files containing english and italian sentences.
 * It then uses `zip` to join the two resulting lists together in a `List<(String, String)>`.
 * 
 * Finally, it uses `flatMap` and `foldLeft` to iterate over the sentences and search words from a predefined list (`searchWords`).
 * At the end, we have a list of [FoundWord] containing all the sentences and words matched.
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

void main() async {
  final collectDoNotation = TaskEither<String, Iterable<FoundWord>>.Do(
    ($) async {
      final linesIta = await $(readFileAsync('./assets/source_ita.txt'));
      final linesEng = await $(readFileAsync('./assets/source_eng.txt'));
      final linesZip = linesIta.zip(linesEng);
      return collectFoundWords(linesZip);
    },
  );

  final collectFlatMap = readFileAsync('./assets/source_ita.txt')
      .flatMap(
        (linesIta) => readFileAsync('./assets/source_eng.txt').map(
          (linesEng) => linesIta.zip(linesEng),
        ),
      )
      .map(collectFoundWords);

  /// Read file async using [TaskEither]
  ///
  /// Since we are using [TaskEither], until we call the `run` method,
  /// no actual reading is performed.
  final task = collectDoNotation.match(
    (l) => print(l),
    (list) {
      /// Print all the found [FoundWord]
      list.forEach(
        (e) => print(
            '${e.index}, ${e.word}(${e.wordIndex}): ${e.english}_${e.italian}\n'),
      );
    },
  );

  /// Run the reading process
  await task.run();
}

/// Read file content in `source` directory using [TaskEither]
///
/// Since the operation may fail, initialize [TaskEither] using `tryCatch`
TaskEither<String, List<String>> readFileAsync(String source) =>
    TaskEither.tryCatch(
      () async => File(source).readAsLines(),
      (error, stackTrace) => 'Error opening file $source: $error',
    );
