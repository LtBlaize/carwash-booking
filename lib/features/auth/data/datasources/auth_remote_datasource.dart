import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });
  Future<void> signOut();
  UserModel? getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final uid = res.user!.id;
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();
    return UserModel.fromMap({...profile, 'email': email});
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final uid = res.user!.id;
    await _client.from('profiles').insert({
      'id': uid,
      'email': email,
      'full_name': fullName,
      'phone': phone,
    });
    return UserModel(
      id: uid,
      email: email,
      fullName: fullName,
      phone: phone,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel(id: user.id, email: user.email ?? '');
  }
}