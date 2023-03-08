import 'package:fpdart/fpdart.dart';

TaskEither<String, String> getUsernameFromId(int id) => TaskEither.of('sandro');
TaskEither<String, String> getProfilePicture(String username) =>
    TaskEither.of('image');
int getPictureWidth(String image) => 10;
TaskEither<String, bool> updatePictureWidth(int width) => TaskEither.of(true);

Future<String> getUsernameFromIdLinear(int id) async => 'sandro';
Future<String> getProfilePictureLinear(String username) async => 'image';
int getPictureWidthLinear(String image) => 10;
Future<bool> updatePictureWidthLinear(int width) async => true;

/// Linear (no fpdart)
Future<bool> changePictureSizeFromIdLinear(int id) async {
  final username = await getUsernameFromIdLinear(id);
  final image = await getProfilePictureLinear(username);
  final width = getPictureWidthLinear(image);
  return updatePictureWidthLinear(width);
}

/// Chaining
TaskEither<String, bool> changePictureSizeFromId(int id) =>
    getUsernameFromId(id)
        .flatMap((username) => getProfilePicture(username))
        .map((image) => getPictureWidth(image))
        .flatMap((width) => updatePictureWidth(width));

/// Do notation
TaskEither<String, bool> changePictureSizeFromIdDo(int id) =>
    TaskEither<String, bool>.Do(
      ($) async {
        final username = await $(getUsernameFromId(id));
        final image = await $(getProfilePicture(username));
        final width = getPictureWidth(image);
        return $(updatePictureWidth(width));
      },
    );

/// [map]: Update value inside [Option]
Option<int> map() => Option.of(10)
    .map(
      (a) => a + 1,
    )
    .map(
      (b) => b * 3,
    )
    .map(
      (c) => c - 4,
    );

Option<int> mapDo() => Option.Do(($) {
      final a = $(Option.of(10));
      final b = a + 1;
      final c = b * 3;
      return c - 4;
    });

/// [flatMap]: Chain [Option]
Option<int> flatMap() => Option.of(10)
    .flatMap(
      (a) => Option.of(a + 1),
    )
    .flatMap(
      (b) => Option.of(b * 3),
    )
    .flatMap(
      (c) => Option.of(c - 4),
    );

Option<int> flatMapDo() => Option.Do(($) {
      final a = $(Option.of(10));
      final b = $(Option.of(a + 1));
      final c = $(Option.of(b * 3));
      return $(Option.of(c - 4));
    });

/// [andThen]: Chain [Option] without storing its value
Option<int> andThen() => Option.of(10).andThen(() => Option.of(20));
Option<int> andThenDo() => Option.Do(($) {
      $(Option.of(10)); // Chain Option, but do not store the result
      return 20;
    });
