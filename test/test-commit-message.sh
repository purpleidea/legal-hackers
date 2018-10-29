#!/bin/bash -e
# tests if commit message conforms to convention

# library of utility functions
# shellcheck disable=SC1091
. test/util.sh

echo running "$0"

ROOT=$(dirname "${BASH_SOURCE}")/..
cd "${ROOT}" || exit 1

travis_regex='^\([a-z0-9]\(\(, \)\|[a-z0-9]\)\+[a-z0-9]: \)\+[A-Z0-9][^:]\+[^:.]$'

# Testing the regex itself.

# Correct patterns.
[[ $(echo "foo, bar: Bar" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "foo: Bar" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "f1oo, b2ar: Bar" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "2foo: Bar" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "foo: bar: Barfoo" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "foo: bar, foo: Barfoo" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "foo: bar, foo: Barfoo" | grep -c "$travis_regex") -eq 1 ]]
[[ $(echo "individuals: lawyer: Adding purpleidea" | grep -c "$travis_regex") -eq 1 ]]

# Space required after :
[[ $(echo "foo:bar" | grep -c "$travis_regex") -eq 0 ]]

# First char must be a a-z0-9
[[ $(echo ", bar: bar" | grep -c "$travis_regex") -eq 0 ]]

# Last chat before : must be a a-z0-9
[[ $(echo "foo, : bar" | grep -c "$travis_regex") -eq 0 ]]

# Last chat before : must be a a-z0-9
[[ $(echo "foo,: bar" | grep -c "$travis_regex") -eq 0 ]]

# No caps
# TODO: why did this break?
#[[ $(echo "Foo: bar" | grep -c "$travis_regex") -eq 0 ]]

# No dot at the end of the message.
[[ $(echo "foo: bar." | grep -c "$travis_regex") -eq 0 ]]

# Capitalize the first word after :
# TODO: why did this break?
#[[ $(echo "foo: bar" | grep -c "$travis_regex") -eq 0 ]]

# More than one char is required before :
[[ $(echo "a: bar" | grep -c "$travis_regex") -eq 0 ]]

# Run checks agains multiple :.
[[ $(echo "a: bar:" | grep -c "$travis_regex") -eq 0 ]]
[[ $(echo "a: bar, fooX: Barfoo" | grep -c "$travis_regex") -eq 0 ]]
[[ $(echo "a: bar, foo: barfoo foo: Nope" | grep -c "$travis_regex") -eq 0 ]]
[[ $(echo "nope a: bar, foo: barfoofoo: Nope" | grep -c "$travis_regex") -eq 0 ]]

test_commit_message() {
	echo "Testing commit message $1"
	if ! git log --format=%s $1 | head -n 1 | grep -q "$travis_regex"
	then
		echo "FAIL: Commit message should match the following regex: '$travis_regex'"
		echo
		echo "eg:"
		echo "individuals: Adding lawyer"
		echo "readme: Changing acceptance criteria"
		echo "faq: Adding a question about billing"
		exit 1
	fi
}

test_commit_message_common_bugs() {
	echo "Testing commit message for common bugs $1"
	if git log --format=%s $1 | head -n 1 | grep -q "^tests:"
	then
		echo 'FAIL: Commit message starts with `tests:`, did you mean `test:` ?'
		exit 1
	fi
	if git log --format=%s $1 | head -n 1 | grep -q "^doc:"
	then
		echo 'FAIL: Commit message starts with `doc:`, did you mean `docs:` ?'
		exit 1
	fi
	if git log --format=%s $1 | head -n 1 | grep -q "^example:"
	then
		echo 'FAIL: Commit message starts with `example:`, did you mean `examples:` ?'
		exit 1
	fi
	if git log --format=%s $1 | head -n 1 | grep -q "^individual:"
	then
		echo 'FAIL: Commit message starts with `individual:`, did you mean `individuals:` ?'
		exit 1
	fi
}

if [[ -n "$TRAVIS_PULL_REQUEST_SHA" ]]
then
	commits=$(git log --format=%H origin/${TRAVIS_BRANCH}..${TRAVIS_PULL_REQUEST_SHA})
	[[ -n "$commits" ]]

	for commit in $commits
	do
		test_commit_message $commit
		test_commit_message_common_bugs $commit
	done
fi
echo 'PASS'
