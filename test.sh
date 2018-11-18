#!/bin/bash -e
# runs all (or selected) test suite(s) in test/ and aggregates results
# Usage:
#	./test.sh
#	./test.sh markdownlint

# library of utility functions
# shellcheck disable=SC1091
. test/util.sh

# allow specifying a single testsuite to run
testsuite="$1"

# print environment when running all testsuites
test -z "$testsuite" && (echo "ENV:"; env; echo; )

# run a test and record failures
function run-testsuite()
{
	testname="$(basename "$1" .sh)"
	# if not running all tests or if this test is not explicitly selected, skip it
	if test -z "$testsuite" || test "test-$testsuite" = "$testname";then
		$@ || failures=$( [ -n "$failures" ] && echo "$failures\\n$@" || echo "$@" )
	fi
}

# only run test if it is explicitly selected, otherwise report it is skipped
function skip-testsuite()
{
	testname=$(basename "$1" .sh)
	# show skip message only when running full suite
	if test -z "$testsuite";then
		echo skipping "$@" "($REASON)"
		echo 'SKIP'
	else
		# if a skipped suite is explicity called, run it anyway
		if test "test-$testsuite" == "$testname";then
			run-testsuite "$@"
		fi
	fi
}

# used at the end to tell if everything went fine
failures=''

run-testsuite ./test/test-misc.sh
run-testsuite ./test/test-bashfmt.sh
run-testsuite ./test/test-commit-message.sh
run-testsuite ./test/test-alphabetical.sh
run-testsuite ./test/test-markdownlint.sh

if [[ -n "$failures" ]]; then
	echo 'FAIL'
	echo 'The following tests have failed:'
	echo -e "$failures"
	echo
	exit 1
fi
echo 'ALL PASSED'
