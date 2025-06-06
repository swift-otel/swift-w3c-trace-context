#!/bin/bash
##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift W3C TraceContext open source project
##
## Copyright (c) 2024 the Swift W3C TraceContext project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##

##===----------------------------------------------------------------------===##
##
## This source file is part of the SwiftNIO open source project
##
## Copyright (c) 2017-2019 Apple Inc. and the SwiftNIO project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
## See CONTRIBUTORS.txt for the list of SwiftNIO project authors
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##

set -eu
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function replace_acceptable_years() {
  # this needs to replace all acceptable forms with 'YEARS'
  sed -e 's/202[4]/YEARS/'
}

printf "=> Checking license headers\n"
tmp=$(mktemp /tmp/.swift-w3c-trace-context-soundness_XXXXXX)

for language in swift-or-c bash dtrace; do
  printf "  * $language... "
  declare -a matching_files
  declare -a exceptions
  expections=( )
  matching_files=( -name '*' )

  case "$language" in
    swift-or-c)
      exceptions=( -name Package.swift -o -name 'Package@*.swift' )
      matching_files=( -name '*.swift' -o -name '*.c' -o -name '*.h' )
      cat > "$tmp" <<"EOF"
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift W3C TraceContext open source project
//
// Copyright (c) YEARS the Swift W3C TraceContext project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
EOF
      ;;
    bash)
      matching_files=( -name '*.sh' )
      cat > "$tmp" <<"EOF"
#!/bin/bash
##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift W3C TraceContext open source project
##
## Copyright (c) YEARS the Swift W3C TraceContext project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##
EOF
      ;;
    dtrace)
      matching_files=( -name '*.d' )
      cat > "$tmp" <<"EOF"
#!/usr/sbin/dtrace -q -s
/*===----------------------------------------------------------------------===*
 *
 *  This source file is part of the Swift W3C TraceContext open source project
 *
 *  Copyright (c) YEARS the Swift W3C TraceContext project authors
 *  Licensed under Apache License v2.0
 *
 *  See LICENSE.txt for license information
 *
 *  SPDX-License-Identifier: Apache-2.0
 *
 *===----------------------------------------------------------------------===*/
EOF
      ;;
    *)
      echo >&2 "ERROR: unknown language '$language'"
      ;;
  esac

  expected_lines=$(cat "$tmp" | wc -l)
  expected_sha=$(cat "$tmp" | shasum)

  (
    cd "$here/.."
    find . \
      \( \! -path './.build/*' \) -a \
      \( \! -path '*/Generated/*' \) -a \
      \( "${matching_files[@]}" \) -a \
      \( \! \( "${exceptions[@]}" \) \) | while read line; do
      if [[ "$(cat "$line" | replace_acceptable_years | head -n $expected_lines | shasum)" != "$expected_sha" ]]; then
        printf "\033[0;31mmissing headers in file '$line'!\033[0m\n"
        diff -u <(cat "$line" | replace_acceptable_years | head -n $expected_lines) "$tmp"
        exit 1
      fi
    done
    printf "\033[0;32mokay.\033[0m\n"
  )
done

rm "$tmp"
