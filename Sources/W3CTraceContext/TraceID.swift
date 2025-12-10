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

/// Uniquely identifies a distributed trace using a 16-byte array.
///
/// [W3C TraceContext: trace-id](https://www.w3.org/TR/trace-context-1/#trace-id)
public struct TraceID: Sendable {

    @usableFromInline
    internal var _bytes: Bytes

    /// The 16 bytes making up the trace ID.
    public var bytes: Bytes {
        _bytes
    }

    /// Create a trace ID from 16 bytes.
    ///
    /// - Parameter bytes: The 16 bytes making up the trace ID.
    public init(bytes: Bytes) {
        self._bytes = bytes
    }

    /// Create a random trace ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the trace ID.
    /// - Returns: A random trace ID.
    public static func random(
        using randomNumberGenerator: inout some RandomNumberGenerator
    ) -> TraceID {
        var id = TraceID.null
        id.withMutableSpan { mutableSpan in
            mutableSpan.withUnsafeMutableBytes { ptr in
                let rand1 = randomNumberGenerator.next()
                let rand2 = randomNumberGenerator.next()
                ptr.storeBytes(of: rand1.bigEndian, toByteOffset: 0, as: UInt64.self)
                ptr.storeBytes(of: rand2.bigEndian, toByteOffset: 8, as: UInt64.self)
            }
        }
        return id
    }

    /// Create a random trace ID.
    ///
    /// - Returns: A random trace ID.
    public static func random() -> TraceID {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
}

extension TraceID: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.withSpan { lSpan in
            rhs.withSpan { rSpan in
                for index in 0 ..< 16 {
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

extension TraceID: Hashable {
    public func hash(into hasher: inout Hasher) {
        withSpan { span in
            for index in span.indices {
                hasher.combine(span[index])
            }
        }
    }
}

extension TraceID: Identifiable {
    public var id: Self { self }
}

// MARK: - Bytes

extension TraceID {
    
    /// A 16-byte array.
    public typealias Bytes = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )
    
    /// A trace ID with all zeros.
    @inlinable
    public static var null: Self {
        TraceID(bytes: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}


// Note: The spans below are provided in a closure, instead of returned, because as of
// Swift 6.2 we're still missing the lifetime features to spell it out correctly.
// In the future, we should add the Span/MutableSpan-returning methods and deprecate
// the closure-taking ones.
extension TraceID {

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
                let span = Span<UInt8>(_unsafeStart: base, count: 16)
                return body(span)
            }
        }
    }

    /// Provides safe, mutable access to the underlying memory.
    /// - Parameter body: The closure within you read the provided span.
    @inlinable public mutating func withMutableSpan<Result: ~Copyable>(
        _ body: (inout MutableSpan<UInt8>) -> Result
    ) -> Result {
        withUnsafeMutableBytes(of: &_bytes) { bytes in
            bytes.withMemoryRebound(to: UInt8.self) { pointer in
                guard let base = pointer.baseAddress else {
                    var span = MutableSpan<UInt8>()
                    return body(&span)
                }
                var span = MutableSpan<UInt8>(_unsafeStart: base, count: 16)
                return body(&span)
            }
        }
    }
}

extension TraceID: CustomStringConvertible {
    /// A 32-character hex string representation of the bytes.
    public var description: String {
        String(decoding: hexBytes, as: UTF8.self)
    }

    /// A 32-character UTF-8 hex byte array representation of the bytes.
    public var hexBytes: [UInt8] {
        withSpan { span in
            var asciiBytes = [UInt8](repeating: 0, count: 32)
            for index in span.indices {
                let byte = span[index]
                asciiBytes[2 * index] = Hex.lookup[Int(byte >> 4)]
                asciiBytes[2 * index + 1] = Hex.lookup[Int(byte & 0x0F)]
            }
            return asciiBytes
        }
    }
}
