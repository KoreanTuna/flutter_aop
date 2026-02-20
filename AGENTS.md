# AGENTS.md

This repository is a Flutter/Dart package that uses build_runner to generate
AOP proxy code. Follow the commands and conventions below when contributing.

## Quick facts
- Package root: /Users/minwoo/Documents/Github/flutter_aop
- Example app: ./example
- Generated files: `*.aop.dart`, `*.aop.bootstrap`, `lib/flutter_aop_bootstrap.g.dart`
- Lint config: `analysis_options.yaml` (includes `package:flutter_lints`)

## Install / bootstrap
- Root deps: `flutter pub get`
- Example deps: `cd example && flutter pub get`

## Build / codegen
- Generate AOP proxies (root):
  - `dart run build_runner build --delete-conflicting-outputs`
- Watch mode (root):
  - `dart run build_runner watch`
- Example app generation (from `example/`):
  - `dart run build_runner build --delete-conflicting-outputs`

## Tests
- Run all tests (root):
  - `flutter test`
- Run a single test file:
  - `flutter test test/runner_test.dart`
  - `flutter test test/proxy_registry_test.dart`
  - `flutter test test/registry_test.dart`
- Run a single test by name:
  - `flutter test test/runner_test.dart --plain-name "runSyncWithAop dispatches before and after hooks"`

## Lint / analyze / format
- Static analysis:
  - `flutter analyze`
- Format all Dart code:
  - `dart format .`
- Formatting note:
  - Generated files declare `// dart format width=80` (keep line length sane).

## Example app run
- From `example/`:
  - `dart run lib/main.dart`

## Repository structure
- Core library: `lib/`
- Generator builders: `lib/src/generator/`
- Tests: `test/`
- Example app: `example/`
- Build config: `build.yaml`

## Generated code policy
- Do not edit generated files by hand.
- Generated outputs include:
  - `*.aop.dart`
  - `*.aop.bootstrap`
  - `lib/flutter_aop_bootstrap.g.dart`
- Update source inputs and re-run build_runner instead.

## Dart/Flutter style rules
- Lint baseline: `analysis_options.yaml` includes `package:flutter_lints`.
- Follow the official Dart style guide.
- Prefer `final` for locals and fields that do not change.
- Use `const` constructors/values when possible.
- Keep method and class names in `lowerCamelCase` / `UpperCamelCase`.
- Keep private helpers `_prefixed` and scoped to the file.

## Imports
- Prefer package imports for public library code:
  - `import 'package:flutter_aop/flutter_aop.dart';`
- Use relative imports for same-folder internals (`lib/src/...`).
- Group imports: SDK, packages, then relative.
- Avoid unused imports (flutter_lints will flag).

## Types and generics
- Prefer explicit types on public APIs.
- Use nullable types (`T?`) where null is allowed; avoid implicit nulls.
- Use `FutureOr<T>` for APIs that accept sync or async (see hooks).

## Error handling
- Use `Error.throwWithStackTrace` when rethrowing with preserved stack trace.
- In AOP runners, use `AopContext.error` + `stackTrace` to propagate failures.
- For sync AOP methods, do not return a `Future` from hooks.

## AOP-specific conventions
- Annotated methods must be instance and public (no static/private).
- `@Aspect` classes must be concrete and have an unnamed constructor without
  required parameters.
- Advice methods must accept exactly one `AopContext` parameter.
- Tags:
  - `@Aop(tag: ...)` matches `@Aspect(tag: ...)` or hook registry tags.
  - `null` tag means global hooks.

## Testing conventions
- Tests use `flutter_test`.
- Clear registries in `setUp()` when mutating global singletons:
  - `AopRegistry.instance.clear()`
  - `AopProxyRegistry.instance.clear()`

## Common workflows
- Change generator logic:
  1) Update `lib/src/generator/*.dart`
  2) Run `dart run build_runner build --delete-conflicting-outputs`
  3) Run `flutter test`
- Change runtime behavior:
  1) Update `lib/src/*.dart`
  2) Run `flutter test`

## When adding files
- Keep public surface exports in `lib/flutter_aop.dart`.
- Keep generator-specific code under `lib/src/generator/`.
- Keep runtime registries in `lib/src/registry.dart` and
  `lib/src/proxy_registry.dart`.

## Contributing checks (from README)
- Run tests (`flutter test`).
- Run code generation (`flutter pub run build_runner build`).

## Notes
- No Cursor rules or Copilot instructions are present in this repo.
- The example project uses GetIt/injectable (see `example/lib/di.dart`).
