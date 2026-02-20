## 1.0.0+7

- feat: Advice `pointcut` 생성 정합성 개선 (`@Before/@After/@OnError/@Around(pointcut: ...)` -> `registerWithPointcut(...)` 생성 지원)
- feat: tag 병합/충돌 규칙 추가 (`effectiveTag = advice.tag ?? aspect.tag`, `pointcut.tag` 충돌 시 생성 단계에서 명확한 오류)
- feat: 훅 실행 순서 결정성 보장 (`order` 동일 시 등록 순서 유지되도록 내부 sequence tie-breaker 도입)
- feat: `AopContext` 확장 (`invocationId`, `startedAt`, `setAttribute/getAttribute/removeAttribute/hasAttribute`)
- feat: 관측성 API 추가 (`AopObservationPhase`, `AopObservationEvent`, `AopObservationSink`, `createObservationHooks`)
- feat: `createObservationHooks`에 개인정보 안전 기본값 및 `slowCallThreshold` 기반 `isSlow` 표식 지원
- feat: 생성기 DX 가드레일 강화 (`@Aop` 대상 private/static/operator 메서드 조기 실패, 메서드 제네릭 프록시 시그니처 반영)
- docs/example: 시나리오 중심 Example 구조 정리 및 AOP 활용 의도/흐름 주석 보강 (영문+국문 병기)
- test: pointcut/ordering/context/observability/generator 회귀 테스트 추가 및 보강

## 0.0.5+6

- Refactor runner exception handling and example

## 0.0.4+5

- Refactor runner exception handling and example

## 0.0.3+4

- Update dependency

## 0.0.2+3

- Update dependency versions

## 0.0.1+2

- Update CHANGELOG.md

## 0.0.1

- Initial version.
