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

/// Uniquely identifies a distributed tracing span using an 8-byte array.
///
/// [W3C TraceContext: parent-id](https://www.w3.org/TR/trace-context-1/#parent-id)
public struct SpanID: Sendable {
    @usableFromInline
    var _bytes: Bytes

    /// The 8 bytes making up the span ID.
    public var bytes: Bytes {
        _bytes
    }

    /// Create a span ID from 8 bytes.
    ///
    /// - Parameter bytes: The 8 bytes making up the span ID.
    public init(bytes: Bytes) {
        _bytes = bytes
    }

    /// Create a random span ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the span ID.
    /// - Returns: A random span ID.
    public static func random(
        using randomNumberGenerator: inout some RandomNumberGenerator
    ) -> SpanID {
        var id = SpanID.null
        id.withMutableSpan { mutableSpan in
            mutableSpan.withUnsafeMutableBytes { ptr in
                ptr.storeBytes(of: randomNumberGenerator.next().bigEndian, as: UInt64.self)
            }
        }
        return id
    }

    /// Create a random span ID.
    ///
    /// - Returns: A random span ID.
    public static func random() -> SpanID {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
}

extension SpanID: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.withSpan { lSpan in
            rhs.withSpan { rSpan in
                for index in 0 ..< 8 {
                    let lValue = lSpan[index]
                    let rValue = rSpan[index]
                    let elementEquals = lValue == rValue
                    guard elementEquals else {
                        return false
                    }
                }
                return true
            }
        }
    }
}

extension SpanID: Hashable {
    public func hash(into hasher: inout Hasher) {
        withSpan { span in
            for index in span.indices {
                hasher.combine(span[index])
            }
        }
    }
}

extension SpanID: Identifiable {
    public var id: Self { self }
}

// MARK: - Bytes

extension SpanID {
    /// An 8-byte array.
    public typealias Bytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    /// A span ID with all zeros.
    @inlinable
    public static var null: Self {
        SpanID(bytes: (0, 0, 0, 0, 0, 0, 0, 0))
    }
}

// Note: The spans below are provided in a closure, instead of returned, because as of
// Swift 6.2 we're still missing the lifetime features to spell it out correctly.
// In the future, we should add the Span/MutableSpan-returning methods and deprecate
// the closure-taking ones.
extension SpanID {
    /// Provides safe, read-only access to the underlying memory.
    /// - Parameter body: The closure within you read the provided span.
    @inlinable public func withSpan<Result: ~Copyable>(
        _ body: (borrowing Span<UInt8>) -> Result
    ) -> Result {
        withUnsafeBytes(of: _bytes) { bytes in
            bytes.withMemoryRebound(to: UInt8.self) { pointer in
                guard let base = pointer.baseAddress else {
                    return body(Span())
                }
                let span = Span<UInt8>(_unsafeStart: base, count: 8)
                return body(span)
            }
        }
    }

    /// Provides safe, mutable access to the underlying memory.
    /// - Parameter body: The closure within you read the provided span.
    @inlinable public mutating func withMutableSpan<Failure: Error, Result: ~Copyable>(
        _ body: (inout MutableSpan<UInt8>) throws(Failure) -> Result
    ) throws(Failure) -> Result {
        try withUnsafeMutableBytes(of: &_bytes) { bytes throws(Failure) in
            try bytes.withMemoryRebound(to: UInt8.self) { pointer throws(Failure) in
                guard let base = pointer.baseAddress else {
                    var span = MutableSpan<UInt8>()
                    return try body(&span)
                }
                var span = MutableSpan<UInt8>(_unsafeStart: base, count: 8)
                return try body(&span)
            }
        }
    }
}

extension SpanID: CustomStringConvertible {
    /// A 16 character hex string representation of the span ID.
    public var description: String {
        String(decoding: hexBytes, as: UTF8.self)
    }

    /// A 16 character UTF-8 hex byte array representation of the bytes.
    public var hexBytes: [UInt8] {
        withSpan { span in
            var asciiBytes = [UInt8](repeating: 0, count: 16)
            for index in span.indices {
                let byte = span[index]
                asciiBytes[2 * index] = Hex.lookup[Int(byte >> 4)]
                asciiBytes[2 * index + 1] = Hex.lookup[Int(byte & 0x0F)]
            }
            return asciiBytes
        }
    }
}
