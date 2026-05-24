import '../models/user_model.dart';

// Interfaz compartida — usa username en vez de email
abstract class AuthDataSource {
  Future<UserModel> login(String username, String password);
}

// Implementación MOCK (fallback)
class AuthMockDataSource implements AuthDataSource {
  @override
  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (username == 'admin' && password == 'techstore2026') {
      return const UserModel(
        id: '1',
        nombre: 'Admin TechStore',
        email: 'admin@techstore.com',
        token: 'mock_jwt_token_techstore_2026',
        rol: 'admin',
      );
    }
    throw Exception('Credenciales incorrectas');
  }
}