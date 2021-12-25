// ignore_for_file: avoid_print

import 'dart:io';
import 'package:fpdart/fpdart.dart';

/**
 * Read lines from a `.txt` file using [TaskEither] of fpdart.
 * 
 * This application reads from two files containing english and italian sentences.
 * It then uses `zip` to join the two resulting lists together in a `List<Tuple2<String, String>>`.
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

void main() async {
  /// Read file async using [TaskEither]
  ///
  /// Since we are using [TaskEither], until we call the `run` method,
  /// no actual reading is performed.
  final task = readFileAsync('./assets/source_ita.txt').flatMap(
    (linesIta) => readFileAsync('./assets/source_eng.txt').map(
      (linesEng) => linesIta.zip(linesEng),
    ),
  );

  /// Run the reading process
  final result = await task.run();

  /// Check for possible error in the reading process
  result.fold(
    /// Print error in the reading process
    (l) => print(l),
    (r) {
      /// If no error occurs, search the words inside each sentence
      /// and compute list of sentence in which you found a word.
      final list = r.flatMapWithIndex((tuple, index) {
        return searchWords.foldLeftWithIndex<List<FoundWord>>(
          [],
          (acc, word, wordIndex) =>
              tuple.second.toLowerCase().split(' ').contains(word)
                  ? [
                      ...acc,
                      FoundWord(
                        index,
                        word,
                        wordIndex,
                        tuple.second.replaceAll(word, '<\$>'),
                        tuple.first,
                      ),
                    ]
                  : acc,
        );
      });

      /// Print all the found [FoundWord]
      list.forEach(
        (e) => print(
            '${e.index}, ${e.word}(${e.wordIndex}): ${e.english}_${e.italian}\n'),
      );
    },
  );
}

/// Read file content in `source` directory using [TaskEither]
///
/// Since the operation may fail, initialize [TaskEither] using `tryCatch`
TaskEither<String, List<String>> readFileAsync(String source) =>
    TaskEither.tryCatch(
      () async => File(source).readAsLines(),
      (error, stackTrace) => 'Error opening file $source: $error',
    );
