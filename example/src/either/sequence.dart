import 'package:fpdart/fpdart.dart';

/// Sequence allows you to unwrap a List of Eithers to an Either of List.
/// It has the type signature (List<Either<L, R>>) => Either<L, List<R>>
/// If any member of the list is a Left type, then the result will be the first Left
/// type sequence encounters
/// If all members of the list are Right, then the result will be a Right<List>>
void main() {
  // final 
}
