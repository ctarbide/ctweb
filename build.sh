#!/bin/sh

# Copyright (c) 2021, C. Tarbide.
# All rights reserved.

# Permission to distribute and use this work for any
# purpose is hereby granted provided this copyright
# notice is included in the copy.  This work is provided
# as is, with no warranty of any kind.

# objective: orchestrate build procedures

set -eu

die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }

srcdir=${0%/*}

make=${MAKE:-bmake}
unset MAKE

gen_makefile_sh_0=tools/gen-Makefile.sh

if [ -f "${gen_makefile_sh_0}" ]; then
    vpath=.
else
    vpath=${srcdir}
fi

gen_makefile_sh=${srcdir}/${gen_makefile_sh_0}

generate_makefile(){
    subdir=${1}; shift
    top=${1}; shift
    vars=${1}; shift
    actions=${1}; shift
    makefile=${1}; shift
    VPATH="${vpath}" \
        SUBDIR="${subdir}" \
        TOP="${top}" \
        MAKEFILE="${makefile}" \
        "${gen_makefile_sh}" \
            "${vars}" \
            "${actions}"
}

generate_makefile tools .. "${srcdir}/vars-host" "${srcdir}/tools/actions" tools/Makefile
generate_makefile src/c ../.. "${srcdir}/vars-host" "${srcdir}/src/c/actions" src/c/Makefile

${make} -C tools all

echo "all done for \"${0##*/}\""
