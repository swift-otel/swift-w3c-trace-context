//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift W3C TraceContext open source project
//
// Copyright (c) 2024 the Swift W3C TraceContext project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import W3CTraceContext
import XCTest

final class SpanIDTests: XCTestCase {
    func test_bytes_returnsEightByteArrayRepresentation() {
        let spanID = SpanID.oneToEight

        XCTAssertEqual(Array(spanID.bytes), [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func test_equatableConformance() {
        let spanID1 = SpanID(bytes: .init((1, 2, 3, 4, 5, 6, 7, 8)))
        let spanID2 = SpanID(bytes: .init((1, 2, 3, 4, 5, 6, 7, 0)))

        XCTAssertEqual(spanID1, spanID1)
        XCTAssertEqual(spanID2, spanID2)
        XCTAssertNotEqual(spanID1, spanID2)
    }

    func test_identifiableConformance() {
        let randomSpanIDs = (0 ..< 100).map { _ in SpanID.random().id }

        XCTAssertEqual(Set(randomSpanIDs).count, 100)
    }

    func test_description_returnsHexStringRepresentation() {
        let spanID = SpanID(bytes: .init((0, 10, 20, 50, 100, 150, 200, 255)))

        XCTAssertEqual("\(spanID)", "000a14326496c8ff")
    }

    func test_random_withCustomNumberGenerator_usesBytesFromRandomNumber() {
        var generator = IncrementingRandomNumberGenerator()

        let spanID1 = SpanID.random(using: &generator)
        XCTAssertEqual(spanID1, SpanID(bytes: .init((0, 0, 0, 0, 0, 0, 0, 0))))

        let spanID2 = SpanID.random(using: &generator)
        XCTAssertEqual(spanID2, SpanID(bytes: .init((0, 0, 0, 0, 0, 0, 0, 1))))
    }

    func test_random_withDefaultNumberGenerator_returnsRandomSpanIDs() {
        let randomSpanIDs = (0 ..< 100).map { _ in SpanID.random() }

        XCTAssertEqual(Set(randomSpanIDs).count, 100)
    }

    // MARK: - Bytes

    func test_spanIDBytes_withUnsafeBytes_invokesClosureWithPointerToBytes() {
        let bytes = SpanID.Bytes((0, 10, 20, 50, 100, 150, 200, 255))

        let byteArray = bytes.withUnsafeBytes { ptr in
            Array(ptr)
        }
        XCTAssertEqual(byteArray, [0, 10, 20, 50, 100, 150, 200, 255])
    }

    func test_spanIDBytes_withUnsafeMutableBytes_allowsMutatingBytesViaClosure() {
        var bytes = SpanID.Bytes((0, 10, 20, 50, 100, 150, 200, 255))

        bytes.withUnsafeMutableBytes { ptr in
            ptr.storeBytes(of: 42, as: UInt8.self)
        }

        XCTAssertEqual(Array(bytes), [42, 10, 20, 50, 100, 150, 200, 255])
    }

    func test_withContiguousStorageIfAvailable_invokesClosureWithPointerToBytes() {
        let bytes = SpanID.Bytes((0, 10, 20, 50, 100, 150, 200, 255))

        let byteArray = bytes.withContiguousStorageIfAvailable { ptr in
            Array(ptr)
        }

        XCTAssertEqual(byteArray, [0, 10, 20, 50, 100, 150, 200, 255])
    }
}
