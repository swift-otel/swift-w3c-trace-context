# Swift W3C TraceContext

[![CI](https://github.com/swift-otel/swift-w3c-trace-context/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-otel/swift-w3c-trace-context/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/swift-otel/swift-w3c-trace-context/graph/badge.svg?token=9656QtdhYA)](https://codecov.io/gh/swift-otel/swift-w3c-trace-context)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-otel%2Fswift-w3c-trace-context%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-otel/swift-w3c-trace-context)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-otel%2Fswift-w3c-trace-context%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-otel/swift-w3c-trace-context)

A Swift implementation of the [W3C Trace Context](https://www.w3.org/TR/trace-context-1/) standard.

## Documentation

Our documentation is hosted on the
[Swift Package Index](https://swiftpackageindex.com/swift-otel/swift-w3c-trace-context/documentation/w3ctracecontext).

## Contributing

Please make sure to run [`./scripts/soundness.sh`](./scripts/soundness.sh) when contributing.
It checks formatting and similar things.

You can ensure it always runs and passes before you push by installing a pre-push hook with git:

```bash
echo './scripts/soundness.sh' > .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```
