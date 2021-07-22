import 'package:fpdart/fpdart.dart';
import 'package:fpdart_json_serializable/user.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    test('toJson (None)', () {
      expect(
        User(
          id: none(),
          birthDate: none(),
          phone: none(),
        ).toJson(),
        {
          "id": null,
          "birthDate": null,
          "phone": null,
        },
      );
    });

    test('toJson (Some)', () {
      expect(
        User(
          id: some(1),
          birthDate: some(DateTime(2020)),
          phone: some('phone'),
        ).toJson(),
        {
          "id": 1,
          "birthDate": "2020-01-01T00:00:00.000",
          "phone": "phone",
        },
      );
    });

    test('fromJson (None)', () {
      final user = User.fromJson(<String, dynamic>{
        "id": null,
        "birthDate": null,
        "phone": null,
      });

      expect(user.id, isA<None>());
      expect(user.birthDate, isA<None>());
      expect(user.phone, isA<None>());
    });

    test('fromJson (Some)', () {
      final user = User.fromJson(<String, dynamic>{
        "id": 1,
        "birthDate": DateTime(2020),
        "phone": "phone",
      });

      expect(user.id, isA<Some>());
      expect(user.id.getOrElse(() => -1), 1);
      expect(user.birthDate.getOrElse(() => DateTime(1990)), DateTime(2020));
      expect(user.phone.getOrElse(() => ''), 'phone');
    });
  });
}
