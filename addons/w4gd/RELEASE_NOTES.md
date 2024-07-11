
# Installation

See full release notes at [sdk.w4.gd](https://sdk.w4.gd).

# Changelog

## [v0.5.1](https://sdk.w4.gd/releases/v0.5.1) - 2024-06-14

### Commits

- Fix auth helper calling an undefined function
- Fix deep promise result resolution
- Use proxy mode for device login on the Web
- Fix realtime reconnect timer not being freed.
- Track refresh tokens, add refresh token login
- Add method for parallel promises await
- Rename rest-client directory to rest

### Merge Requests

- Fix auth helper calling an undefined function (see [!30](https://sdk.w4.gd/mrs/30))
- Fix deep promise result resolution (see [!29](https://sdk.w4.gd/mrs/29))
- Use proxy mode for device login on the Web (see [!28](https://sdk.w4.gd/mrs/28))
- Track refresh tokens, add refresh token login (see [!26](https://sdk.w4.gd/mrs/26))
- Add method for parallel promises await (see [!25](https://sdk.w4.gd/mrs/25))
- Fix realtime reconnect timer not being freed. (see [!27](https://sdk.w4.gd/mrs/27))
- Rename rest-client directory (see [!23](https://sdk.w4.gd/mrs/23))

## [v0.5.0](https://sdk.w4.gd/releases/v0.5.0) - 2024-05-08

### Commits

- New editor plugin UI

### Merge Requests

- New editor plugin UI (see [!20](https://sdk.w4.gd/mrs/20))

## [v0.4.4](https://sdk.w4.gd/releases/v0.4.4) - 2024-05-08

### Commits

- Fix server uploader preset detection in Godot 4.3
- Fix auth helper error signals argument type

### Merge Requests

- Fix server uploader preset detection in Godot 4.3 (see [!22](https://sdk.w4.gd/mrs/22))
- Fix auth helper error signals argument type (see [!19](https://sdk.w4.gd/mrs/19))

## [v0.4.3](https://sdk.w4.gd/releases/v0.4.3) - 2024-04-04

### Commits

- Move reconnect logic inside module

### Merge Requests

- Move reconnect logic inside module (see [!18](https://sdk.w4.gd/mrs/18))

## [v0.4.2](https://sdk.w4.gd/releases/v0.4.2) - 2024-04-03

### Commits

- Fix watchers using old realtime syntax
- Add Auth node helper
- Fix incorrect lobby delete behavior

### Merge Requests

- Add Auth node helper (see [!13](https://sdk.w4.gd/mrs/13))
- Fix watchers using old realtime syntax (see [!16](https://sdk.w4.gd/mrs/16))
- Fix incorrect lobby delete behavior (see [!15](https://sdk.w4.gd/mrs/15))

## [v0.4.1](https://sdk.w4.gd/releases/v0.4.1) - 2024-03-08

### Commits

- Update to new schema name 'w4analytics'
- Expose request, result, and error types
- Prevent error during signup with email verification
- Fix cyclic references memory leak
- Fix requests lifecycle and memory leak
- Always emit identity_changed on token reset
- Improving handling of empty base urls

### Merge Requests

- Update to new schema name 'w4analytics' (see [!14](https://sdk.w4.gd/mrs/14))
- Expose request, result, and error types (see [!12](https://sdk.w4.gd/mrs/12))
- Prevent error during signup with email verification (see [!10](https://sdk.w4.gd/mrs/10))
- Fix cyclic references memory leaks (see [!9](https://sdk.w4.gd/mrs/9))
- Improve handling of empty credentials (see [!8](https://sdk.w4.gd/mrs/8))

## [v0.4.0](https://sdk.w4.gd/releases/v0.4.0) - 2024-02-12

### Commits

- [**breaking**] Compatibility with W4 Cloud v0.3+
- Automate release process

### Merge Requests

- [**breaking**] Compatibility with W4 Cloud v0.3+ (see [!7](https://sdk.w4.gd/mrs/7))

## [v0.3.2](https://sdk.w4.gd/releases/v0.3.2) - 2024-02-09

### Commits

- Fix packaging command
- Always run tests
- Automate package and release
- Reopen realtime channels which still have subscriptions
- Fix realtime spamming close channel requests
- Fix WebRTCManager emitting signals too soon

### Merge Requests

- Automate package and release (see [!5](https://sdk.w4.gd/mrs/5))
- Fix realtime channel close, reopen channels with active subscriptions (see [!4](https://sdk.w4.gd/mrs/4))
- Fix WebRTCManager emitting signals too soon (see [!3](https://sdk.w4.gd/mrs/3))

## [v0.3.1](https://sdk.w4.gd/releases/v0.3.1) - 2023-11-05

### Commits

- Make W4Client always process
- Rename inner Player class to W4Player

## [v0.3.0](https://sdk.w4.gd/releases/v0.3.0) - 2023-11-02

### Commits

- W4GD IS OPEN SOURCE

