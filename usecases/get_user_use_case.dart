import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaweave/core/errors/failures.dart';
import 'package:mangaweave/core/usecases/usecase.dart';
import '../test.dart';

class GetUserUseCase extends UseCase<String, GetUserUseCaseParams>{
   final Test test;
   GetUserUseCase(this.test);
  
  @override
  Future<Either<Failure, String>> call(GetUserUseCaseParams params) {
   return test.getUser(params.userId);
  }
}

class GetUserUseCaseParams extends Equatable{
  final String userId;
  const GetUserUseCaseParams(this.userId);
  @override
  List<Object?> get props => [userId];
}
