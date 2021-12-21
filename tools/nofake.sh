#!/bin/sh

set -eu

if [ x"${ZSH_VERSION:-}" != x ]; then
    # let zsh behave like dash, bash and others shells when expanding
    # parameters
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

opts=
chunks=
sources=
output=

while [ $# -gt 0 ]; do
    case "${1}" in
        -L*) opts="${opts} '${1}'" ;;
        -R*) chunks="${chunks} '${1}'" ;;

        -o|--output) output=${2}; shift ;;
        --output=*) output=${1#*=} ;;
        -o*) output=${1#??} ;;

        -) sources="${sources} '-'" ;;
        -*)
            echo "${0##*/}: Unrecognized option '${1}'." 1>&2
            exit 1
            ;;
        *) sources="${sources} '${SRC_PREFIX}${1}'" ;;
    esac
    shift
done

if [ x"${output}" = x ]; then
    echo "${0##*/}: No output specified, use '-o' option." 1>&2
    exit 1
fi

stamp=${output}.stamp
tmpfile=.tmp.${output}

uptodate(){
    test="test '(' -e '${stamp}' -a -e '${output}'"
    eval "set -- ${sources}"
    for src do test="${test} -a '${stamp}' -nt ${src}"; done
    test="${test} ')'"
    eval "${test}"
}

if ! uptodate; then
    eval "set -- ${opts} ${chunks} ${sources}"
    ${NOFAKE} ${NOFAKEFLAGS} "$@" >"${tmpfile}"
    if ! ${CMP} "${tmpfile}" "${output}"; then
        ${ECHO} "Generate "'"'"${output}"'"'"."
        ${MV} "${tmpfile}" "${output}"
        ${CHMOD} "${output}"
    else
        ${RM} "${tmpfile}"
        ${ECHO} 'Output "'"${output}"'" did not change.'
    fi
    ${TOUCH} "${stamp}"
else
    ${ECHO} 'Output "'"${output}"'" is up to date.'
fi
