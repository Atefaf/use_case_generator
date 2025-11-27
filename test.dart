
import 'package:dartz/dartz.dart';
//!dart use_case_generator.dart -r test_repository.dart
 abstract class TestRepository {
  Future<Either<Failure, String>> getUser(String userId);
  Future<Either<Failure, List<String>>> getAllUsers();
  Future<Either<Failure, void>> deleteUser(String userId);
}


class Failure {}