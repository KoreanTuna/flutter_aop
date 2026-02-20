# flutter_aop

Flutter/Dart 코드에서 스프링 AOP처럼 어노테이션만 붙이면 프록시가 자동으로 생성되고, `@Aspect` 클래스로 공통 관심사를 분리할 수 있는 패키지입니다. `build_runner`로 `.aop.dart` 파일을 만들고, `aopWrap()`을 통해 실제 구현을 프록시로 감싸면 됩니다.

## 주요 기능

- `@Aop` 어노테이션: 특정 메소드에 before/after/onError/around 훅을 선언적으로 설정
- `@Aspect`, `@Before`, `@After`, `@OnError`, `@Around`: 스프링과 비슷한 형태의 어드바이스 클래스를 작성하고 자동 등록
- `@Around` 어드바이스: `proceed()` 패턴으로 메소드 실행을 완전히 제어
- `Pointcut` 표현식: 클래스/메소드 이름 패턴으로 어드바이스 적용 대상 필터링
- `@Aspect(order: n)`: 여러 Aspect 간 실행 순서 명시적 제어
- `TypeKey`: 제네릭 클래스에 대한 타입 안전한 프록시 지원
- `AopProxyRegistry` + `aopWrap()`: 생성된 프록시를 직접 다루지 않고, 런타임에서 알아서 감싸도록 지원
- `AopRegistry`: 전역/태그별/Pointcut별 훅 관리, 테스트에서 초기화 가능
- `createObservationHooks()`: 별도 의존성 없이 구조화된 관측 이벤트(before/after/error) 생성
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

## 기본 사용법

1. 공통 로직을 담고 싶은 메소드에 `@Aop` 어노테이션을 붙입니다.
2. `@Aspect` 클래스를 만들고, 조인 포인트에 맞춰 `@Before`, `@After`, `@OnError`, `@Around` 메소드를 작성합니다.
3. 다음 명령으로 코드 생성을 실행합니다.

   ```
   dart run build_runner build --delete-conflicting-outputs
   ```

4. 앱 시작 시 생성된 `runFlutterAopBootstrap()`을 한 번 호출해 모든 프록시/Aspect 등록을 실행합니다.
5. 이후 서비스 생성 시 `aopWrap(MyService())` 를 호출하면 해당 타입의 프록시가 자동으로 감싸집니다.

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

---

## 고급 기능

### @Around 어드바이스

가장 강력한 어드바이스 타입으로, 메소드 실행을 완전히 감쌀 수 있습니다. `ctx.proceed()`를 호출하여 원본 메소드 실행 시점을 제어합니다.

```dart
@Aspect(tag: 'timing')
class TimingAspect {
  @Around()
  Future<dynamic> measureTime(AopContext ctx) async {
    final stopwatch = Stopwatch()..start();
    try {
      // 원본 메소드 실행
      final result = await ctx.proceed();
      return result;
    } finally {
      stopwatch.stop();
      print('${ctx.methodName} 소요시간: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
```

**캐싱 예제** - `proceed()`를 호출하지 않고 캐시된 값 반환:

```dart
@Aspect(tag: 'cached')
class CacheAspect {
  final _cache = <String, dynamic>{};

  @Around()
  Future<dynamic> cacheAdvice(AopContext ctx) async {
    final key = '${ctx.methodName}_${ctx.positionalArguments}';

    // 캐시 히트 시 원본 메소드 건너뛰기
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    // 캐시 미스 시 원본 실행 후 캐시 저장
    final result = await ctx.proceed();
    _cache[key] = result;
    return result;
  }
}
```

### Pointcut 표현식

태그 대신 클래스/메소드 이름 패턴으로 어드바이스를 적용할 수 있습니다.

```dart
@Aspect()
class RepositoryLogger {
  // *Repository 클래스의 find*로 시작하는 메소드에만 적용
  @Before(pointcut: Pointcut(classPattern: '*Repository', methodPattern: 'find*'))
  void logFindOperations(AopContext ctx) {
    print('Repository 조회: ${ctx.positionalArguments}');
  }
}

// 또는 런타임에 직접 등록
AopRegistry.instance.registerWithPointcut(
  AopHooks(before: (ctx) => print('Service 호출: ${ctx.methodName}')),
  pointcut: Pointcut(classPattern: '*Service'),
);
```

**지원하는 패턴:**
- `*` - 0개 이상의 문자 매칭 (`*Service` → UserService, LoginService)
- `?` - 정확히 1개의 문자 매칭 (`get?ser` → getUser)

**미리 정의된 Pointcut:**
- `Pointcuts.allServices` - `*Service` 클래스
- `Pointcuts.allRepositories` - `*Repository` 클래스
- `Pointcuts.allGetters` - `get*` 메소드
- `Pointcuts.saveOperations` - `save*` 메소드
- `Pointcuts.deleteOperations` - `delete*` 메소드

**태그 병합 규칙 (`@Aspect` + `pointcut`)**
- `effectiveTag = advice.tag ?? aspect.tag`
- `pointcut.tag`가 비어 있으면 `effectiveTag`가 자동 주입됩니다.
- `pointcut.tag`와 `effectiveTag`가 모두 존재하고 값이 다르면 코드 생성 시 즉시 실패합니다.

### 실행 순서 제어

여러 Aspect가 같은 태그에 등록되었을 때 실행 순서를 명시적으로 지정할 수 있습니다.

```dart
@Aspect(tag: 'auth', order: 1)  // 가장 먼저 실행
class SecurityAspect {
  @Before()
  void checkAuth(AopContext ctx) {
    print('1. 인증 체크');
  }
}

@Aspect(tag: 'auth', order: 2)  // 두 번째로 실행
class LoggingAspect {
  @Before()
  void logBefore(AopContext ctx) {
    print('2. 로깅');
  }
}

@Aspect(tag: 'auth', order: 3)  // 마지막으로 실행
class MetricsAspect {
  @Before()
  void recordMetrics(AopContext ctx) {
    print('3. 메트릭 기록');
  }
}
```

`order` 값이 작을수록 먼저 실행됩니다. 같은 `order` 값을 가진 Aspect는 등록 순서대로 실행됩니다.

### 제네릭 클래스 지원

제네릭 클래스에 대해서는 `TypeKey`를 사용하여 타입별로 다른 프록시를 등록할 수 있습니다.

```dart
// 제네릭 Repository 클래스
class Repository<T> {
  @Aop(tag: 'repo')
  Future<T?> findById(int id) async { /* ... */ }
}

// 등록 시 TypeKey 사용
AopProxyRegistry.instance.registerGeneric<Repository<User>>(
  (target, {hooks}) => RepositoryAopProxy(target, hooks: hooks),
  typeKey: TypeKey.withArgs(Repository, [User]),
);

AopProxyRegistry.instance.registerGeneric<Repository<Product>>(
  (target, {hooks}) => RepositoryAopProxy(target, hooks: hooks),
  typeKey: TypeKey.withArgs(Repository, [Product]),
);

// 래핑 시에도 TypeKey 사용
final userRepo = aopWrapGeneric(
  Repository<User>(),
  TypeKey.withArgs(Repository, [User]),
);

final productRepo = aopWrapGeneric(
  Repository<Product>(),
  TypeKey.withArgs(Repository, [Product]),
);
```

### 개선된 AopContext API

`AopContext`에 유틸리티 메소드가 추가되어 더 편리하게 사용할 수 있습니다.

```dart
@Before()
void logBefore(AopContext ctx) {
  // 타입 안전한 인자 접근
  final userId = ctx.getArg<int>(0);
  final options = ctx.getNamedArg<Map<String, dynamic>>('options');
  final debug = ctx.getNamedArgOr<bool>('debug', false);  // 기본값 지정

  // 현재 상태 확인
  print('상태: ${ctx.state}');  // AopExecutionState.beforeInvocation

  // 조인포인트 정보
  print('호출: ${ctx.joinPointDescription}');  // "UserService.login"
}

@Before()
void cacheCheck(AopContext ctx) {
  final cached = cache.get(ctx.positionalArguments);
  if (cached != null) {
    // skipWithResult()로 깔끔하게 스킵 처리
    ctx.skipWithResult(cached);
  }
}
```

### 관측성 훅 팩토리

공통 로깅/성능 계측이 필요하면 `createObservationHooks()`를 등록해
구조화된 이벤트를 수집할 수 있습니다.

```dart
AopRegistry.instance.register(
  createObservationHooks(
    sink: (event) {
      print(
        '[${event.phase.name}] ${event.joinPointDescription} '
        'elapsed=${event.elapsed.inMilliseconds}ms slow=${event.isSlow}',
      );
    },
    slowCallThreshold: const Duration(milliseconds: 200),
  ),
  tag: 'auth',
);
```

### 에러 복구

`@OnError` 훅에서 에러를 복구하고 폴백 값을 반환할 수 있습니다.

```dart
@OnError()
void handleError(AopContext ctx) {
  if (ctx.getError<NetworkException>() != null) {
    print('네트워크 오류 발생, 캐시된 데이터 반환');

    // 에러 제거하고 폴백 값 설정
    ctx.error = null;
    ctx.result = getCachedData();

    // 이후 @After 훅도 정상적으로 실행됨
  }
}
```

---

## 생성물 확인

`build_runner` 실행 후 원본 파일 옆에 `*.aop.dart`가 생기며, 여기에는

- `<클래스명>AopProxy` 구현
- `AopProxyRegistry`에 프록시 팩토리를 등록하는 초기화 코드
- `AopRegistry`에 어드바이스를 등록하는 코드 (order 포함)
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

터미널 로그를 보면 before/after/error 훅이 순서대로 실행되는 것을 확인할 수 있습니다.

## GetIt / Injectable 연동

GetIt + `injectable` 조합을 사용할 때는 모듈에서 `aopWrap()`을 통해 프록시를 등록하고, DI 초기화 전에 `runFlutterAopBootstrap()`을 호출하면 됩니다.

```dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  runFlutterAopBootstrap();
  AopRegistry.instance.register(
    createObservationHooks(
      sink: (event) => print('[${event.phase.name}] ${event.joinPointDescription}'),
    ),
    tag: 'auth',
  );
  getIt.init();
}

@module
abstract class ServiceModule {
  @lazySingleton
  LoginService loginService() => aopWrap(LoginService());
}
```

전체 예시는 `example/lib/di.dart` 파일을 참고하세요.

## 추가 팁

- 동기 메소드에는 동기 훅만 연결할 수 있습니다. 비동기가 필요하면 원본 메소드를 `async`로 변경하세요.
- `@Around` 어드바이스도 동기 메소드에서는 동기 함수여야 합니다.
- `AopContext.positionalArguments` / `namedArguments`로 호출 인자를 그대로 받을 수 있습니다.
- 캐시 등으로 원본 메소드를 건너뛰고 싶다면:
  - `@Before`에서: `ctx.skipWithResult(cachedValue)` 사용
  - `@Around`에서: `ctx.proceed()` 호출하지 않고 값 직접 반환
- `@OnError` 훅에서 `ctx.error = null` 설정하고 `ctx.result`를 채우면 실패를 복구할 수 있습니다.

## build_runner

개발 중에는 watch 모드를 사용하면 편합니다.

```
dart run build_runner watch
```

충돌 파일 삭제 옵션(`--delete-conflicting-outputs`)을 붙이지 않으면 예전 생성물이 남아 있을 수 있으니 주의하세요.

## API 요약

| 어노테이션 | 설명 |
|-----------|------|
| `@Aop(tag, before, after, onError)` | 메소드를 AOP 대상으로 지정 |
| `@Aspect(tag, order)` | Aspect 클래스 정의, order로 실행 순서 제어 |
| `@Before(tag, pointcut)` | 메소드 실행 전 호출 |
| `@After(tag, pointcut)` | 메소드 성공 후 호출 |
| `@OnError(tag, pointcut)` | 메소드 실패 시 호출 |
| `@Around(tag, pointcut)` | 메소드 실행을 완전히 감싸서 제어 |

| 클래스/함수 | 설명 |
|------------|------|
| `AopContext` | 메소드 호출 정보와 제어 기능 제공 |
| `AopHooks` | before/after/onError/around 콜백 컬렉션 |
| `AopRegistry` | 전역 훅 레지스트리 |
| `AopProxyRegistry` | 프록시 팩토리 레지스트리 |
| `aopWrap<T>()` | 객체를 프록시로 래핑 |
| `aopWrapGeneric<T>()` | 제네릭 객체를 TypeKey로 래핑 |
| `createObservationHooks()` | before/after/error 관측 이벤트 훅 생성 |
| `Pointcut` | 클래스/메소드 패턴 매칭 |
| `TypeKey` | 제네릭 타입 식별자 |
