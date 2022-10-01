import 'package:flutter_application_1/models/pomotodo_user.dart';

abstract class IAuthService {
  Future<PomotodoUser> createUserWithEmailAndPassword({required String email, required String password});
  Future<PomotodoUser> signInEmailAndPassword({required String email, required String password});
  Future<void> signOut();
  Stream<PomotodoUser?> get onAuthStateChanged; 
}