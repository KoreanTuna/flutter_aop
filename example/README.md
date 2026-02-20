# flutter_aop example

기능별 시나리오를 한 번에 실행하는 콘솔 예제입니다.

## 실행 방법

```bash
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run lib/main.dart
```

## 포함된 시나리오

1. Basic hooks (`auth`)
- `@Before/@After/@OnError` 동작 확인
- 성공 로그인 + 실패 로그인 흐름
- 소스: `lib/scenarios/basic_auth/`

2. Around cache (`cache`)
- `@Around`에서 `ctx.proceed()` 제어
- 동일 요청 두 번째 호출은 캐시 HIT
- 소스: `lib/scenarios/cache/`

3. Pointcut (`*Repository` + `find*`)
- `@Before(pointcut: ...)` 매칭 확인
- `find*`만 매칭, `save*`는 비매칭
- 소스: `lib/scenarios/pointcut/`

4. Ordering (`pipeline`)
- `@Aspect(order: 1/2/3)` 실행 순서 확인
- 소스: `lib/scenarios/ordering/`

5. Error recovery (`payment`)
- `@OnError`에서 `ctx.error = null`, `ctx.result` 설정
- 복구 후 `@After` 실행 확인
- 소스: `lib/scenarios/recovery/`

6. Short-circuit (`feature-flag`)
- `@Before`에서 `ctx.skipWithResult(...)` 사용
- 원본 메소드 실행 없이 반환
- 소스: `lib/scenarios/short_circuit/`

## Observability

`di.dart`에서 `createObservationHooks(...)`를 전역 등록합니다.

- invocation id
- join point
- elapsed/slow 여부
- 인자/결과/에러

출력으로 각 시나리오의 실행 흐름을 확인할 수 있습니다.
