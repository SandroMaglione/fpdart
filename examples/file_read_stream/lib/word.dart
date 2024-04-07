import 'package:equatable/equatable.dart';

class WordPair {
  final int idCollection;
  final int idWord1;
  final int idWord2;
  const WordPair(this.idCollection, this.idWord1, this.idWord2);

  @override
  String toString() {
    return "($idCollection)$idWord1|$idWord2";
  }
}

class Word extends Equatable {
  final int idWord;
  final String word;
  const Word(this.idWord, this.word);

  @override
  String toString() {
    return "($idWord)$word";
  }

  @override
  List<Object?> get props => [idWord];

  Map<String, dynamic> toJson() => {
        '"idWord"': idWord,
        '"word"': '"$word"',
      };
}

class WordFull extends Equatable {
  final int idCollection;
  final Word word1;
  final Word word2;
  const WordFull(this.idCollection, this.word1, this.word2);

  @override
  String toString() {
    return "👉 $idCollection\n   $word1\n   $word2";
  }

  @override
  List<Object?> get props => [word1, word2];

  Map<String, dynamic> toJson() => {
        '"idCollection"': idCollection,
        '"word1"': word1.toJson(),
        '"word2"': word2.toJson(),
      };
}
