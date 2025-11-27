import 'package:dartz/dartz.dart';
import 'test.dart';
//!dart repo_impl_generator.dart -r auth_repository.dart 
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String displayName,
    String? referralCode,
  });
  
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> verifyEmail();
  Future<Either<Failure, void>> resendVerificationEmail(String email);
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
  });
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
  });
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Stream<UserEntity?> get authStateChanges;
}


class UserEntity {
   
}