import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Stream<User?> get userStream => _auth.authStateChanges();

  
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;


  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }
}