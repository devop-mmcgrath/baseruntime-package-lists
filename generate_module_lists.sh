#!/bin/bash

# Created by argbash-init v2.4.0
# ARG_OPTIONAL_SINGLE([module],[],[Which module are we generating data on?],[base-runtime])
# ARG_OPTIONAL_SINGLE([version],[],[The Fedora release number],[25])
# ARG_OPTIONAL_SINGLE([milestone],[],[The Fedora release milestone],[GA])
# ARG_OPTIONAL_REPEATED([arch],[],[Which CPU architecture(s)?],['aarch64' 'armv7hl' 'i686' 'ppc64' 'ppc64le' 'x86_64'])
# ARG_OPTIONAL_SINGLE([repo-path],[],[The base path for repositories],[./repo])
# ARG_OPTIONAL_SINGLE([data-path],[],[The base path for processed data],[./data])
# ARG_HELP([Script to produce the dependency data files for modules])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.4.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option()
{
	local first_option all_short_options
	all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}



# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_module="base-runtime"
_arg_version="25"
_arg_milestone="GA"
_arg_arch=('aarch64' 'armv7hl' 'i686' 'ppc64' 'ppc64le' 'x86_64')
_arg_repo_path="./repo"
_arg_data_path="./data"

print_help ()
{
	echo "Script to produce the dependency data files for modules"
	printf 'Usage: %s [--module <arg>] [--version <arg>] [--milestone <arg>] [--arch <arg>] [--repo-path <arg>] [--data-path <arg>] [-h|--help]\n' "$0"
	printf "\t%s\n" "--module: Which module are we generating data on? (default: '"base-runtime"')"
	printf "\t%s\n" "--version: The Fedora release number (default: '"25"')"
	printf "\t%s\n" "--milestone: The Fedora release milestone (default: '"GA"')"
	printf "\t%s\n" "--arch: Which CPU architecture(s)? (default array: ('aarch64' 'armv7hl' 'i686' 'ppc64' 'ppc64le' 'x86_64') )"
	printf "\t%s\n" "--repo-path: The base path for repositories (default: '"./repo"')"
	printf "\t%s\n" "--data-path: The base path for processed data (default: '"./data"')"
	printf "\t%s\n" "-h,--help: Prints help"
}

# THE PARSING ITSELF
while test $# -gt 0
do
	_key="$1"
	case "$_key" in
		--module|--module=*)
			_val="${_key##--module=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_module="$_val"
			;;
		--version|--version=*)
			_val="${_key##--version=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_version="$_val"
			;;
		--milestone|--milestone=*)
			_val="${_key##--milestone=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_milestone="$_val"
			;;
		--arch|--arch=*)
			_val="${_key##--arch=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_arch+=("$_val")
			;;
		--repo-path|--repo-path=*)
			_val="${_key##--repo-path=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_repo_path="$_val"
			;;
		--data-path|--data-path=*)
			_val="${_key##--data-path=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_data_path="$_val"
			;;
		-h*|--help)
			print_help
			exit 0
			;;
		*)
			_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
			;;
	esac
	shift
done

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

module=$_arg_module
version=$_arg_version
milestone=$_arg_milestone
repocfg="$(readlink -f $_arg_repo_path)/Fedora-$version-$milestone-repos.cfg"

if [ $milestone == "GA" ]; then
    moduleroot="$(readlink -f $_arg_data_path)/Fedora/$version/$module"
else
    moduleroot="$(readlink -f $_arg_data_path)/Fedora/${version}_${milestone}/$module"
fi

for arch in ${_arg_arch[@]}; do
    modulearchroot=$moduleroot/$arch
    pkgfile="$modulearchroot/toplevel-binary-packages.txt"
    hintsfile="$modulearchroot/hints.txt"

    basearch=$($SCRIPT_DIR/get_basearch $arch)

    hints=""
    while read hint; do
        hints+="--hint $hint "
    done < $hintsfile

    # Clear any existing file, if present
    > $modulearchroot/runtime-binary-packages-full.txt
    > $modulearchroot/runtime-binary-packages-short.txt
    > $modulearchroot/runtime-source-packages-full.txt
    > $modulearchroot/runtime-source-packages-short.txt
    > $modulearchroot/selfhosting-binary-packages-full.txt
    > $modulearchroot/selfhosting-binary-packages-short.txt
    > $modulearchroot/selfhosting-source-packages-full.txt
    > $modulearchroot/selfhosting-source-packages-short.txt

    # Depchase the binary and source packages for the runtime
    echo "Processing runtime for $arch"
    cat $pkgfile |
    xargs depchase -a $basearch -c $repocfg resolve $hints |
    while IFS= read -r nevra; do
          [[ "$nevra" == *.src || "$nevra" == *.nosrc ]] && type_="source" || type_="binary"
          name=${nevra%-*-*}
          echo "$nevra" >> $modulearchroot/runtime-$type_-packages-full.txt
          echo "$name" >> $modulearchroot/runtime-$type_-packages-short.txt
    done

    # Depchase the binary and source packages for the self-hosting set
    echo "Processing self-hosting for $arch"
    cat $pkgfile |
    xargs depchase -a $basearch -c $repocfg resolve --selfhost $hints |
    while IFS= read -r nevra; do
          [[ "$nevra" == *.src || "$nevra" == *.nosrc ]] && type_="source" || type_="binary"
          name=${nevra%-*-*}
          echo "$nevra" >> $modulearchroot/selfhosting-$type_-packages-full.txt
          echo "$name" >> $modulearchroot/selfhosting-$type_-packages-short.txt
    done

    LC_SAVED=$LC_ALL
    export LC_ALL=C
    for f in $modulearchroot/{runtime,selfhosting}-{binary,source}-packages-{full,short}.txt; do
      sort -u $f -o $f
    export LC_ALL=$LC_SAVED
    done

done

# ] <-- needed because of Argbash