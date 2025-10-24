import 'package:mymusicplayer_new/core/configs/usecase/auth/usecase.dart';
import 'package:mymusicplayer_new/data/models/auth/signin_user_req.dart';
import 'package:dartz/dartz.dart';

import '../../../../domain/repository/auth/auth.dart';
import '../../../../presentation/service_locator.dart';

class  SigninUseCase implements UseCase<Either,SigninUserReq> {
  SigninUseCase(AuthRepository authRepository);

  @override
  Future<Either> call({ SigninUserReq ?params}) async {
    return sl<AuthRepository>().signin(params!);
  }

}