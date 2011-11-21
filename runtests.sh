#!/bin/bash

set -e

RESULT=0
TESTS="rot13 bockbeer gameoflife"
for test in $TESTS; do
	echo "=== $test ==="
	echo "Compiling"
	./bf_firm tests/$test.bf
	echo "Running"
	OUT="$(mktemp)"
	./a.out < tests/$test.in > "$OUT"
	if ! diff -u "tests/$test.out" "$OUT"; then
		echo "Bad results"
		RESULT=1
	else
		echo "Results ok"
	fi
	rm -f "$OUT"
done

exit $RESULT
