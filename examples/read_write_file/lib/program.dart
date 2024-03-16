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

Iterable<_FoundWord> _collectFoundWords(
  List<String> searchWords,
  Iterable<(String, String)> iterable,
) =>
    iterable.flatMapWithIndex(
      (tuple, index) => searchWords.foldLeftWithIndex<List<_FoundWord>>(
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

typedef Env = ({
  FileSystem fileSystem,
  File sourceIta,
  File sourceEng,
  List<String> searchWords,
});

final program = Effect<Env, FileSystemError, Iterable<_FoundWord>>.gen(
  (_) async {
    final env = await _(Effect.env());

    final linesIta = await _(
      env.fileSystem.readAsLines().provide(
            (env) => env.sourceIta,
          ),
    );

    final linesEng = await _(
      env.fileSystem.readAsLines().provide(
            (env) => env.sourceEng,
          ),
    );

    final linesZip = linesIta.zip(linesEng);
    return _collectFoundWords(env.searchWords, linesZip);
  },
);
