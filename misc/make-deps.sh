#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"	# dir!
cd "${ROOT}" >/dev/null

sudo_command=$(command -v sudo)

YUM=`command -v yum 2>/dev/null`
DNF=`command -v dnf 2>/dev/null`
APT=`command -v apt-get 2>/dev/null`
BREW=`command -v brew 2>/dev/null`
PACMAN=`command -v pacman 2>/dev/null`

# if DNF is available use it
if [ -x "$DNF" ]; then
	YUM=$DNF
fi

if [ -z "$YUM" -a -z "$APT" -a -z "$BREW" -a -z "$PACMAN" ]; then
	echo "The package managers can't be found."
	exit 1
fi

if [ ! -z "$YUM" ]; then
	$sudo_command $YUM install -y time
fi
if [ ! -z "$APT" ]; then
	# `realpath` is a more universal alternative to `readlink -f` for absolute path resolution
	# (-f is missing on BSD/macOS), but older Debian/Ubuntu's don't include it in coreutils yet.
	# https://unix.stackexchange.com/a/136527
	$sudo_command $APT install -y realpath || true
	$sudo_command $APT install -y time || true
fi

if [ ! -z "$BREW" ]; then
	# coreutils contains gtimeout, gstat, etc
	$BREW install coreutils || true
fi

#if [ ! -z "$PACMAN" ]; then
#	$sudo_command $PACMAN -S --noconfirm --asdeps --needed TODO
#fi

command -v mdl &>/dev/null || gem install mdl || true	# for linting markdown files
