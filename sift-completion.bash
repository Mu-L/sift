_sift() {
	local cur prev opts types cores
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD - 1]}"

	# Handle long and short opts separately to avoid cluttering output with too many completion suggestions
	if [[ ${cur} == --* ]]; then # long opts
		opts="$(sift --help | sift --no-byte-offset --no-column --no-line-number '\s+(--[\w-]+)(?:\s|=)' --replace '$1' --output-sep ' ')"
		COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
		return 0
	elif [[ ${cur} == -* ]]; then # short opts
		opts="$(sift --help | sift --no-byte-offset --no-column --no-line-number '\s+(-\w)(?:,\s)' --replace '$1' --output-sep ' ')"
		COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
		return 0
	fi

	case "${prev}" in
	-j | --cores)
		cores="$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)"
		COMPREPLY=($(compgen -W "$(eval echo "{0..${cores}}")" -- ${cur}))
		return 0
		;;
	-t | -T | --type | --no-type | --del-type)
		types="$(sift --list-types | sift --no-byte-offset --no-column --no-line-number '^([\w-]+)\s+:' --replace '$1' --output-sep ' ')"
		COMPREPLY=($(compgen -W "${types}" -- ${cur}))
		return 0
		;;
	-V | --version)
		return 0
		;;
	esac

	[[ $(type -t _comp_compgen) == "function" ]] && _comp_compgen -a filedir || _filedir
	return 0
}
complete -F _sift sift

# vim: set filetype=bash shiftwidth=4 tabstop=4 noexpandtab autoindent:
