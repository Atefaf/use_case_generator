import 'package:dartz/dartz.dart';
import 'package:mangaweave/core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource auth;

  AuthRepositoryImpl(this.auth);

  @override
  Future<Either<Failure, UserEntity>> login() async {
    try {
      final result = await auth.login();
      return Right(result);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register() async {
    try {
      final result = await auth.register();
      return Right(result);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await auth.logout();
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final result = await auth.getCurrentUser();
      return Right(result);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail() async {
    try {
      await auth.verifyEmail();
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) async {
    try {
      await auth.resendVerificationEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword() async {
    try {
      await auth.resetPassword();
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile() async {
    try {
      final result = await auth.updateProfile();
      return Right(result);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await auth.deleteAccount();
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final result = await auth.signInWithGoogle();
      return Right(result);
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }
}
