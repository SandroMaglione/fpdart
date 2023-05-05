import 'package:fpdart/fpdart.dart';

/// Helper functions ⚙️ (sync)
String addNamePrefix(String name) => "Mr. $name";
String addEmailPrefix(String email) => "mailto:$email";
String decodeName(int code) => "$code";

/// API functions 🔌 (async)
Future<String> getUsername() => Future.value("Sandro");
Future<int> getEncodedName() => Future.value(10);

Future<String> getEmail() => Future.value("@");

Future<bool> sendInformation(String usernameOrName, String email) =>
    Future.value(true);

Future<bool> withFuture() async {
  late String usernameOrName;
  late String email;

  try {
    usernameOrName = await getUsername();
  } catch (e) {
    try {
      usernameOrName = decodeName(await getEncodedName());
    } catch (e) {
      throw Exception("Missing both username and name");
    }
  }

  try {
    email = await getEmail();
  } catch (e) {
    throw Exception("Missing email");
  }

  try {
    final usernameOrNamePrefix = addNamePrefix(usernameOrName);
    final emailPrefix = addEmailPrefix(email);
    return await sendInformation(usernameOrNamePrefix, emailPrefix);
  } catch (e) {
    throw Exception("Error when sending information");
  }
}

TaskEither<String, bool> withTask() => TaskEither.tryCatch(
      getUsername,
      (_, __) => "Missing username",
    )
        .alt(
          () => TaskEither.tryCatch(
            getEncodedName,
            (_, __) => "Missing name",
          ).map(
            decodeName,
          ),
        )
        .map(
          addNamePrefix,
        )
        .flatMap(
          (usernameOrNamePrefix) => TaskEither.tryCatch(
            getEmail,
            (_, __) => "Missing email",
          )
              .map(
                addEmailPrefix,
              )
              .flatMap(
                (emailPrefix) => TaskEither.tryCatch(
                  () => sendInformation(usernameOrNamePrefix, emailPrefix),
                  (_, __) => "Error when sending information",
                ),
              ),
        );

Task<int> getTask() => Task(() async {
      print("I am running [Task]...");
      return 10;
    });

Future<int> getFuture() async {
  print("I am running [Future]...");
  return 10;
}

void main() {
  Task<int> taskInt = getTask();
  Future<int> futureInt = getFuture();

  // Future<int> taskRun = taskInt.run();
}
