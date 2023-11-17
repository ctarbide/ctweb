#!/bin/sh

set -eu

die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }

if [ x"${ZSH_VERSION:-}" != x ]; then
    # let zsh behave like ash, ksh and other standard
    # shells when expanding parameters
    setopt sh_word_split
fi

# environment variables that can affect the result

SRC_PREFIX=${SRC_PREFIX:-}
NOFAKE=${NOFAKE:-nofake}
NOFAKEFLAGS=${NOFAKEFLAGS:-}
ECHO=${ECHO:-echo}
MV=${MV:-mv -f}
RM=${RM:-rm -f}
TOUCH=${TOUCH:-touch}
CHMOD=${CHMOD:-chmod 0444}
CMP=${CMP:-cmp -s}

u0Aa(){
    perl -e'@map=map{chr}48..57,65..90,97..122;
        $c = $ARGV[0];
        while($c and read(STDIN,$d,64)){
            for $x (unpack(q{C*},$d)) {
                last unless $c;
                next if $x >= scalar(@map);
                $c--;
                print($map[$x]);
            }
        }' -- "${1}" </dev/urandom
}
r0Aa(){
    perl -e'@map=map{chr}48..57,65..90,97..122;
        sub c{$map[int(rand(scalar(@map)))]}
        for ($c=$ARGV[0];$c;$c--) { print(c) }' -- "${1}"
}
temporary_file(){
    if type mktemp >/dev/null 2>&1; then
        tmpfile=`mktemp`
    elif type perl >/dev/null 2>&1 && test -r /dev/urandom; then
        tmpfile="/tmp/tmp.`u0Aa 12`"
        ( umask 0177; : > "${tmpfile}" )
    elif type perl >/dev/null 2>&1; then
        tmpfile="/tmp/tmp.`r0Aa 12`"
        ( umask 0177; : > "${tmpfile}" )
    else
        die 1 'error: mktemp not found'
    fi
    echo "${tmpfile}"
}
tmpfiles=
rm_tmpfiles(){
    eval "set -- ${tmpfiles}"
    rm -f -- "$@"
}
# 0:exit, 1:hup, 2:int, 3:quit, 15:term
trap 'rm_tmpfiles' 0 1 2 3 15

opts=
chunks=
sources=
output=

while [ $# -gt 0 ]; do
    case "${1}" in
        -L*|--error) opts="${opts:+${opts} }'${1}'" ;;
        -R*) chunks="${chunks:+${chunks} }'${1}'" ;;

        -o|--output) output=${2}; shift ;;
        --output=*) output=${1#*=} ;;
        -o*) output=${1#??} ;;

        -) sources="${sources:+${sources} }'-'" ;;
        -*)
            ${ECHO} "${0##*/}: Unrecognized option '${1}'." 1>&2
            exit 1
            ;;
        *) sources="${sources} '${SRC_PREFIX}${1}'" ;;
    esac
    shift
done

if [ x"${output}" = x ]; then
    ${ECHO} "${0##*/}: No output specified, use '-o' option." 1>&2
    exit 1
fi

stamp=${output}.stamp

inputid(){
    perl -MCwd=realpath -MDigest::SHA=sha256_hex \
        -le'print(sha256_hex(join(q{&}, map { realpath $_ } @ARGV)))' \
        -- "$@"
}

uptodate(){
    if [ ! -e "${stamp}" ]; then
        false
    else
        current_id=`head -n1 "${stamp}"`
        if [ ! -e "${output}" -o x"${sources_id}" != x"${current_id}" ]; then
            false
        else
            eval "set -- ${sources}"
            test=
            for src do test="${test:+${test} -a }'${stamp}' -nt ${src}"; done
            eval "test '(' ${test} ')'"
        fi
    fi
}

tmpfile=`temporary_file`
tmpfiles="${tmpfiles} '${tmpfile}'"

eval "set -- ${sources}"
sources_id=`inputid "$@"`

if ! uptodate; then
    eval "set -- ${opts} ${chunks} ${sources}"
    ${NOFAKE} ${NOFAKEFLAGS} "$@" >"${tmpfile}"
    if ! ${CMP} "${tmpfile}" "${output}"; then
        ${ECHO} "Generate "'"'"${output}"'"'"." 1>&2
        ${MV} "${tmpfile}" "${output}"
        ${CHMOD} "${output}"
    else
        ${RM} "${tmpfile}"
        ${ECHO} 'Output "'"${output}"'" did not change.' 1>&2
    fi
    ${ECHO} "${sources_id}" > "${stamp}"
else
    ${ECHO} 'Output "'"${output}"'" is up to date.' 1>&2
fi
