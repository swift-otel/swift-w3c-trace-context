//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift W3C TraceContext open source project
//
// Copyright (c) 2025 the Swift W3C TraceContext project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XCTest

func XCTAssertEqualUInt8Spans(
    _ lhs: Span<UInt8>, 
    _ rhs: Span<UInt8>,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    for index in lhs.indices {
        XCTAssertEqual(lhs[index], rhs[index], "Index: \(index)", file: file, line: line)
    }
}
