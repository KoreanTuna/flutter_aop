import 'di.dart';
import 'login_service.dart';

Future<void> main() async {
  await configureDependencies();

  final service = getIt<LoginService>();
  await _successfulLogin(service);
}

Future<void> _successfulLogin(LoginService service) async {
  await service.login('gmail', 'gmail!');
}
