import 'package:mymusicplayer_new/data/models/auth/create_user_req.dart';
import 'package:mymusicplayer_new/data/models/auth/signin_user_req.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthFirebaseService {
  Future<Either<String, String>> signup(CreateUserReq createUserReq );
  Future<Either<String,String>>signin(SigninUserReq signinUserReq);
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {

  @override
  Future<Either<String,String>>signin(SigninUserReq signinUserReq) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email,
        password: signinUserReq.password,
      );
      return const Right('Signin was successful');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'wrong password provided for that user.';
      } else {
        message = 'Signup failed: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, String>> signup(CreateUserReq createUserReq) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );
      return const Right('Signup was successful');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = 'Signup failed: ${e.message}';
      }
      return Left(message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }
}

