#! /usr/bin/env bash

set -eo pipefail

[ "$#" -lt 2 ] && {
	echo "usage: ${PROGRAM} data <DIRECTORY> <PROGRAM> ARGS ..." >&2
	exit 1
}

path="${1%/}"
check_sneaky_paths "$path"
passTar="${PREFIX}/${path}.gpg"
passTarDir="${passTar%"/${path}.gpg"}"
passName="${passTar%.gpg}"
passName="${passName##*/}"
mkdir -p -- "$passTarDir"
set_gpg_recipients "$passTarDir"
set_git "$passTar"
tmpdir
tmpPath="${SECURE_TMPDIR}/${passName}"
tmpTar="${tmpPath}.tar.gz"
tmpPath2="${SECURE_TMPDIR}/old.${passName}"
tmpTar2="${tmpPath2}.tar"
mkdir -p -- "$tmpPath" "$tmpPath2"

[ -f "$passTar" ] && {
	$GPG -d -o "$tmpTar" "${GPG_OPTS[@]}" "$passTar" || exit 1
	gzip -d "$tmpTar" || exit 1
	tar -xf "${tmpTar%.gz}" -C "$tmpPath" || exit 1
	cp -rf "$tmpPath/." "$tmpPath2" || exit 1
}

prog="$2"
shift 2
PASS_DATA="$tmpPath" eval "${prog} ${*}"

[ -f "$passTar" ] && diff -r "$tmpPath" "$tmpPath2" 2>/dev/null && return

tar -cf "${tmpTar2}" -C "$tmpPath" . || exit 1
gzip "$tmpTar2" || exit 1

$GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passTar" "${GPG_OPTS[@]}" "${tmpTar2}.gz" || exit 1

git_add_file "$passTar" "Update data in ${path}."
