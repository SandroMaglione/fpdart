import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import './word.dart';

typedef Env = ({
  String wordPairCsv,
  String wordsCsv,
  String outputPath,
});

final wordPairs = Effect<Env, String, List<WordPair>>.gen(($) async {
  final env = $.sync(Effect.env());
  final inputFile = File(env.wordPairCsv);

  final lines = inputFile.openRead().transform(utf8.decoder).transform(
        LineSplitter(),
      );

  final wordCollection = <WordPair>[];
  await for (var line in lines) {
    final split = line.split(',');
    if (split.length != 3) {
      return $.sync(Effect.fail("Missing word-pair info at: '$line'"));
    }

    final wordInfo = $
        .sync(Effect.all([
          Effect.fromNullable(
            int.tryParse(split[0]),
            onNull: () => "Missing id collection",
          ),
          Effect.fromNullable(
            int.tryParse(split[1]),
            onNull: () => "Missing id word1",
          ),
          Effect.fromNullable(
            int.tryParse(split[2]),
            onNull: () => "Missing id word2",
          ),
        ]))
        .toList();

    wordCollection.add(WordPair(wordInfo[0], wordInfo[1], wordInfo[2]));
  }

  return wordCollection;
});

final words = Effect<Env, String, List<WordFull>>.gen(($) async {
  final env = $.sync(Effect.env());
  final wordCollection = await $.async(wordPairs);

  final inputFile = File(env.wordsCsv);
  final lines = inputFile.openRead().transform(utf8.decoder).transform(
        LineSplitter(),
      );

  final wordMap = <int, String>{};
  await for (var line in lines) {
    final split = line.split(',');
    if (split.length < 2) {
      return $.sync(Effect.fail("Missing word info at: '$line'"));
    }

    final idWord = $.sync(Effect.fromNullable(
      int.tryParse(split[0]),
      onNull: () => "Missing id word",
    ));
    final word = split[1];

    wordMap[idWord] = word;
  }

  final wordFullList = <WordFull>[];
  for (var entry in wordCollection) {
    final word1 = $.sync(Effect.fromNullable(
      wordMap[entry.idWord1],
      onNull: () => "Missing word 1 at: $entry",
    ));
    final word2 = $.sync(Effect.fromNullable(
      wordMap[entry.idWord2],
      onNull: () => "Missing word 2 at: $entry",
    ));

    wordFullList.add(
      WordFull(
        entry.idCollection,
        Word(entry.idWord1, word1),
        Word(entry.idWord2, word2),
      ),
    );
  }

  return wordFullList.toSet().toList();
});

final program = Effect<Env, String, Unit>.gen(($) async {
  final env = $.sync(Effect.env());
  final wordFullList = await $.async(words);

  final outputFile = File(env.outputPath);
  await $.async(
    Effect.tryCatch(
      execute: () => outputFile.writeAsString(
        "[${wordFullList.map((e) => e.toJson()).join(",\n")}]",
      ),
      onError: (_, __) => "Error while writing output file",
    ),
  );

  return unit;
});

void main() async {
  await program.provideEnv((
    wordPairCsv: "./lib/word_pairs.csv",
    wordsCsv: "./lib/words.csv",
    outputPath: "./lib/output.json",
  )).matchCause(
    onFailure: (cause) {
      print(cause);
    },
    onSuccess: (_) {
      print("Success");
    },
  ).runFutureExit();
}
