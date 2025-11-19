import 'package:flutter_aop/flutter_aop.dart';

part 'login_service.aop.dart';

class LoginService {
  @Aop(
    tag: 'auth',
    description: 'Authenticate the user against a remote server',
  )
  Future<void> login(String id, String password) async {
    print('[Service] Starting login for $id');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    print('[Service] Login successful for $id');
  }

  Future<void> noneAopLogin(String id, String password) async {
    print('[Service] Starting login for $id');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    print('[Service] Login successful for $id');
  }
}
