import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaweave/core/errors/failures.dart';
import 'package:mangaweave/core/usecases/usecase.dart';
import '../test.dart';

class DeleteUserUseCase extends UseCase<void, DeleteUserUseCaseParams>{
   final Test test;
   DeleteUserUseCase(this.test);
  
  @override
  Future<Either<Failure, void>> call(DeleteUserUseCaseParams params) {
   return test.deleteUser(params.userId);
  }
}

class DeleteUserUseCaseParams extends Equatable{
  final String userId;
  const DeleteUserUseCaseParams(this.userId);
  @override
  List<Object?> get props => [userId];
}
