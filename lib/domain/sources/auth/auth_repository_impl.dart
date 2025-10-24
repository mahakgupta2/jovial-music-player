import 'package:dartz/dartz.dart';
import '../../../data/models/auth/create_user_req.dart';
import '../../../data/models/auth/signin_user_req.dart';
import '../../../presentation/service_locator.dart';
import '../../repository/auth/auth.dart';
import '../../sources/auth/auth_firebase_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(pragma);

  @override
  Future<Either<String, String>> signin(SigninUserReq signinUserReq) async {
    return await sl<AuthFirebaseService>().signin(signinUserReq);
  }

  @override
  Future<Either<String, String>> signup(CreateUserReq createUserReq) async {
    return await sl<AuthFirebaseService>().signup(createUserReq);
  }
}

