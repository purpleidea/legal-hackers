#!/bin/bash

# common settings and functions for test scripts

# get the fully expanded path of the project directory
ROOT="$(realpath "$(dirname "$(realpath "${BASH_SOURCE}")")/..")"

if [[ $(uname) == "Darwin" ]] ; then
	export timeout="gtimeout"
	export mktemp="gmktemp"
	export STAT="gstat"
else
	export timeout="timeout"
	export mktemp="mktemp"
	export STAT="stat"
fi

fail_test()
{
	echo -e "FAIL: $@"
	exit 1
}

function run-test()
{
	"$@" || failures=$( [ -n "$failures" ] && echo "$failures\\n$@" || echo "$@" )
}
