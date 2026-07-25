#!/bin/sh
# Test runner for rush02 (number-to-words converter).
# TDD harness: runs each tests/*.sh. The solution lives in srcs/ + includes/,
# built via the top-level Makefile into ./rush-02.
#
# Usage:
#   ./run_tests.sh              # run every test file
#   ./run_tests.sh rush02       # only tests/rush02.sh
#   NO_COLOR=1 ./run_tests.sh   # disable ANSI colors
#
# Exit status: 0 if every selected test file passed, 1 otherwise.

set -u
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TESTS="$DIR/tests"

if [ "$#" -gt 0 ]; then
	sel=$*
else
	# Auto-discover: every tests/*.sh present, in sorted order.
	sel=$(for t in "$TESTS"/*.sh; do
		[ -e "$t" ] || continue
		b=${t##*/}
		[ "$b" = "lib.sh" ] && continue
		printf '%s ' "${b%.sh}"
	done)
fi

fails=0
for t_name in $sel; do
	t="$TESTS/$t_name.sh"
	printf '\n=== %s ===\n' "$t_name"
	if [ ! -f "$t" ]; then
		printf '  (no test file %s)\n' "$t"
		continue
	fi
	sh "$t" || fails=$((fails + 1))
done

printf '\n========================\n'
if [ "$fails" -eq 0 ]; then
	printf 'ALL SELECTED TESTS PASSED\n'
	exit 0
else
	printf '%s TEST FILE(S) FAILED\n' "$fails"
	exit 1
fi
