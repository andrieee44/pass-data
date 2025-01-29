#! /usr/bin/env bash

cmd_data_exec() {
	[ "$#" -lt 2 ] && {
		echo "usage: ${PROGRAM} data <DIRECTORY> <PROGRAM> ARGS ..." >&2
		exit 1
	}

	path="${1%/}"

	check_sneaky_paths "$path"

	fullPath="${PREFIX}/${path}"

	[ -f "${fullPath}.gpg" ] && die "must be a directory"

	tmpdir

	tmpPath="${SECURE_TMPDIR}/${path}"

	mkdir -p "$fullPath" "$tmpPath"
	set_gpg_recipients "$path"
	set_git "$fullPath"

	find "$fullPath" -type f | while read -r file; do
		file="${file#"${PREFIX}/${path}/"}"
		file="${file%.gpg}"

		$GPG -d -o "${tmpPath}/${file}" "${GPG_OPTS[@]}" "${PREFIX}/${path}/${file}.gpg" || exit 1
	done

	program="$2"
	shift 2
	PASS_DATA="$tmpPath" eval "$program" "$@"

	find "$tmpPath" -type f | while read -r file; do
		file="${file#"${tmpPath}/"}"
		passFile="${PREFIX}/${path}/${file}.gpg"
		tmpFile="${tmpPath}/${file}"

		[ -f "$passFile" ] && $GPG -d -o - "${GPG_OPTS[@]}" "$passFile" 2>/dev/null | diff - "$tmpFile" >/dev/null 2>&1 && continue
		mkdir -p "${passFile%/*}"
		$GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passFile" "${GPG_OPTS[@]}" "$tmpFile" || exit 1
	done

	git_add_file "$fullPath" "Update data in ${path}."
}

cmd_data_exec "$@"
