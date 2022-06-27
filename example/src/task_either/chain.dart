import 'package:fpdart/fpdart.dart';

typedef MessageResponse = String;
typedef AnalyticsResponse = int;

TaskEither<String, MessageResponse> resendVerificationEmail =
    TaskEither.of("done");

TaskEither<String, AnalyticsResponse> registerAnalytics = TaskEither.of(1);

Future<void> main() async {
  /**
   * This will execute `resendVerificationEmail`
   * 
   * If `resendVerificationEmail` is successful, then it will chain a call to `registerAnalytics`
   * while still returning the result from `resendVerificationEmail`
   */
  final taskEither = resendVerificationEmail.chainFirst(
    (_) => registerAnalytics,
  );

  final result = await taskEither.run();
  print(result); // Right("done")
}
