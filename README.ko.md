# flutter_aop

Flutter/Dart 코드에서 스프링 AOP처럼 어노테이션만 붙이면 프록시가 자동으로 생성되고, `@Aspect` 클래스로 공통 관심사를 분리할 수 있는 패키지입니다. `build_runner`로 `.aop.dart` 파일을 만들고, `aopWrap()`을 통해 실제 구현을 프록시로 감싸면 됩니다.

## 주요 기능

- `@Aop` 어노테이션: 특정 메소드에 before/after/onError 훅을 선언적으로 설정
- `@Aspect`, `@Before`, `@After`, `@OnError`: 스프링과 비슷한 형태의 어드바이스 클래스를 작성하고 자동 등록
- `AopProxyRegistry` + `aopWrap()`: 생성된 프록시를 직접 다루지 않고, 런타임에서 알아서 감싸도록 지원
- `AopRegistry`: 전역/태그별 훅 관리, 테스트에서 초기화 가능
- 비동기/동기 메소드 모두 지원, `AopContext`로 실행 정보 제공

## 시작하기

```yaml
dependencies:
  flutter_aop:
    path: ../flutter_aop # 또는 pub.dev 등록 후 버전 명시

dev_dependencies:
  build_runner: ^2.10.4
```

모든 AOP 대상 파일에 `part '*.aop.dart';`를 추가하세요. 예)

```dart
import 'package:flutter_aop/flutter_aop.dart';
part 'login_service.aop.dart';
```

## 사용 방법

1. 공통 로직을 담고 싶은 메소드에 `@Aop` 어노테이션을 붙입니다.
2. `@Aspect` 클래스를 만들고, 조인 포인트에 맞춰 `@Before`, `@After`, `@OnError` 메소드를 작성합니다. 각 메소드는 `AopContext` 하나를 파라미터로 받아야 합니다.
3. 다음 명령으로 코드 생성을 실행합니다.

   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. `dart run build_runner build --delete-conflicting-outputs` 를 실행해 `.aop.dart` 및 `flutter_aop_bootstrap.g.dart` 파일을 생성합니다.
5. 앱 시작 시 생성된 `runFlutterAopBootstrap()`을 한 번 호출해 모든 프록시/Aspect 등록을 실행합니다.
6. 이후 서비스 생성 시 `aopWrap(MyService())` 를 호출하면 해당 타입의 프록시가 자동으로 감싸집니다. 태그별 훅은 `@Aop(tag: ...)`와 `@Aspect(tag: ...)` 로 매칭합니다.

```dart
class LoginService {
  @Aop(tag: 'auth')
  Future<void> login(String id, String password) async {
    // 구현
  }
}

@Aspect(tag: 'auth')
class LoggingAspect {
  const LoggingAspect();

  @Before()
  void before(AopContext ctx) => print('before ${ctx.methodName}');

  @After()
  void after(AopContext ctx) => print('after ${ctx.methodName}');

  @OnError()
  void onError(AopContext ctx) => print('error ${ctx.methodName}');
}

Future<void> main() async {
  runFlutterAopBootstrap(); // 생성된 부트스트랩 호출
  final service = aopWrap(LoginService());
  await service.login('gmail', '1234');
}
```

## 생성물 확인

`build_runner` 실행 후 원본 파일 옆에 `*.aop.dart`가 생기며, 여기에는

- `<클래스명>AopProxy` 구현
- `AopProxyRegistry`에 프록시 팩토리를 등록하는 초기화 코드
- `AopRegistry`에 어드바이스를 등록하는 코드
- 공개 함수 `flutterAopBootstrap...` 가 포함됩니다.

또한 프로젝트 루트에는 `flutter_aop_bootstrap.g.dart`가 생성되며, 이 함수들을 모두 모아 `runFlutterAopBootstrap()` 를 노출합니다.

## 예제 프로젝트

`example/` 디렉터리에는 `LoginService`와 두 가지 Aspect(Logging/Metrics)를 활용한 전체 흐름이 담겨 있습니다.

```
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run lib/main.dart
```

터미널 로그를 보면 before/after/error 훅이 순서대로 실행되는 것을 확인할 수 있습니다. `example/lib/login_service.dart`와 `example/lib/aspect/*.dart`를 참고하고, 생성된 `flutter_aop_bootstrap.g.dart`가 `runFlutterAopBootstrap()`을 노출합니다.

## GetIt / Injectable 연동

GetIt + `injectable` 조합을 사용할 때는 모듈에서 `aopWrap()`을 통해 프록시를 등록하고, DI 초기화 전에 `runFlutterAopBootstrap()`을 호출하면 됩니다.

```dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  runFlutterAopBootstrap();
  getIt.init();
}

@module
abstract class ServiceModule {
  @lazySingleton
  LoginService loginService() => aopWrap(LoginService());
}
```

전체 예시는 `example/lib/di.dart` 파일을 참고하세요.

## build_runner

개발 중에는 watch 모드를 사용하면 편합니다.

```
dart run build_runner watch
```

충돌 파일 삭제 옵션(`--delete-conflicting-outputs`)을 붙이지 않으면 예전 생성물이 남아 있을 수 있으니 주의하세요.
