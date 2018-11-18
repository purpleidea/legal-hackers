#!/bin/bash -e
# tests if individuals file is in alphabetical order

# library of utility functions
# shellcheck disable=SC1091
. test/util.sh

echo running "$0"

ROOT=$(dirname "${BASH_SOURCE}")/..
cd "${ROOT}" || exit 1

file="individuals.md"

# ensure entries in the file are sorted
# start when we find the first row divider character group in the table: |---|
# TODO: not sure if this is the most correct regexp, but it seems to work well
start=$(($(grep -n '\\n\|\-\-\-\|\\n' $file | awk -F ':' '{print $1}' | head -1) + 1))
if ! diff <(tail -n +$start $file | sort) <(tail -n +$start $file); then
	echo "FAIL: $file is not in alphabetical order"
	exit 1
fi

echo 'PASS'
