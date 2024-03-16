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
  await program.runFuture(
    (
      fileSystem: FileSystemLive(),
      sourceEng: File('./assets/source_eng.txt'),
      sourceIta: File('./assets/source_ita.txt'),
    ),
  );
}
