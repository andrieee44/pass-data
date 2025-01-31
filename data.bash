#! /usr/bin/env bash

cmd_data_exec() {
	set -eo pipefail

	[ "$#" -lt 2 ] && {
		echo "usage: ${PROGRAM} data <DIRECTORY> <PROGRAM> ARGS ..." >&2
		exit 1
	}

	path="${1%/}"
	check_sneaky_paths "$path"
	passTar="${PREFIX}/${path}.gpg"
	passTarDir="$(dirname -- "$passTar")"
	mkdir -p -- "$passTarDir"
	set_gpg_recipients "$passTarDir"
	set_git "$passTar"
	tmpdir
	tmpPath="${SECURE_TMPDIR}/$(basename -- "${passTar%.gpg}")"
	tmpTar="${tmpPath}.tar"
	tmpTarGz="${tmpTar}.gz"
	mkdir -p -- "$tmpPath"

	[ -f "$passTar" ] && {
		$GPG -d -o "$tmpTarGz" "${GPG_OPTS[@]}" "$passTar" || exit 1
		gzip -d "$tmpTarGz" || exit 1
		sumA="$(tarsum <"$tmpTar")" || exit 1
		tar -xf "$tmpTar" -C "$tmpPath" || exit 1
	}

	prog="$2"
	shift 2
	PASS_DATA="$tmpPath" eval "${prog} ${*}"

	tmpTar2="$(dirname "$tmpTar")/tmp.$(basename "$tmpTar")"

	tar -cf "$tmpTar2" -C "$tmpPath" . || exit 1
	sumB="$(tarsum <"$tmpTar2")" || exit 1
	gzip "$tmpTar2" || exit 1

	[ -f "$passTar" ] && [ "$sumA" = "$sumB" ] && return

	$GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passTar" "${GPG_OPTS[@]}" "${tmpTar2}.gz" || exit 1

	git_add_file "$passTar" "Update data in ${path}."
}

cmd_data_exec "$@"
