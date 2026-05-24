import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'auth_mock_datasource.dart';

class AuthRemoteDataSource implements AuthDataSource {
  final ApiClient apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRemoteDataSource(this.apiClient);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await apiClient.dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });

    final data = response.data;
    // La API devuelve { access_token, token_type, ... }
    final token = data['access_token'] ?? data['token'] ?? '';
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(key: AppConstants.usernameKey, value: username);

    return UserModel(
      id: data['id']?.toString() ?? '1',
      nombre: data['nombre'] ?? data['username'] ?? username,
      email: data['email'] ?? '$username@techstore.com',
      token: token,
      rol: data['rol'] ?? data['role'] ?? 'admin',
    );
  }
}