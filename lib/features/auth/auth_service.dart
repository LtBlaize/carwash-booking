import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> register({
  required String email,
  required String password,
  required String name,
  required String phone,
}) async {
  try {
    print("STEP 1: Creating Auth user");

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    print("STEP 2: Auth success UID = $uid");

    print("STEP 3: Writing Firestore");

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': name,
      'phone': phone,
      'role': 'customer',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("STEP 4: Firestore success");

    return userCredential;
  } catch (e, stack) {
    print("🔥 REGISTER FAILED: $e");
    print(stack);
    rethrow;
  }
}

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}