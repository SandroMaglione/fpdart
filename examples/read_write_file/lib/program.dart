import 'dart:io';

import 'package:fpdart/fpdart.dart';

import 'file_system.dart';

class _FoundWord {
  final int index;
  final String word;
  final int wordIndex;
  final String english;
  final String italian;
  const _FoundWord(
    this.index,
    this.word,
    this.wordIndex,
    this.english,
    this.italian,
  );
}

/// Word to search in each sentence
const _searchWords = ['that', 'and', 'for'];

Iterable<_FoundWord> _collectFoundWords(
  Iterable<(String, String)> iterable,
) =>
    iterable.flatMapWithIndex(
      (tuple, index) => _searchWords.foldLeftWithIndex<List<_FoundWord>>(
        [],
        (acc, word, wordIndex) =>
            tuple.$2.toLowerCase().split(' ').contains(word)
                ? [
                    ...acc,
                    _FoundWord(
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

typedef Env = ({FileSystem fileSystem, File sourceIta, File sourceEng});

final program = Effect<Env, FileSystemError, Iterable<_FoundWord>>.gen(
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
    return _collectFoundWords(linesZip);
  },
)
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
