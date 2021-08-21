#!/bin/sh

# Copyright (c) 2021, C. Tarbide.
# All rights reserved.

# Permission to distribute and use this work for any
# purpose is hereby granted provided this copyright
# notice is included in the copy.  This work is provided
# as is, with no warranty of any kind.

# objective: use a posix shell (dash, mksh) and awk
# (nawk, mawk) to generate a portable Makefile

set -eu

die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }

awk=${AWK:-nawk}
unset AWK

strip_r_slash(){ echo "$@" | "${awk}" '{sub(/\/+$/,"");print}'; }

cat_in_path(){
    f=${1}; shift
    t=${1}; shift
    while true; do
        h=`strip_r_slash ${t%%:*}`
        t0=${t#*:}
        if [ -f "${h}/${f}" ]; then
            cat "${h}/${f}"
            return 0
        fi
        [ x"${t0}" != x"${t}" ] || break
        t=${t0}
    done
    die 1 "error: file not found: \"${f}\""
}

if [ x"${VPATH:-}" != "x" ]; then
    for i in "$@"; do
        cat_in_path "${i}" "${VPATH}"
    done
else
    for i in "$@"; do
        cat "${i}"
    done
fi
