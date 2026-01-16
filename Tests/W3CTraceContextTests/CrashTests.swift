import Testing
@testable import W3CTraceContext

@Test
func crashTest() throws {
    let traceContext = try TraceContext(
        traceParentHeaderValue: "00-0Af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01",
        traceStateHeaderValue: "foo=bar,tenant1@system=1,tenant2@system=2"
    )
    print(traceContext)
}
