
/* Copyright (c) 2021, C. Tarbide.
 * All rights reserved.
 *
 * Permission to distribute and use this work for any
 * purpose is hereby granted provided this copyright
 * notice is included in the copy.  This work is provided
 * as is, with no warranty of any kind.
 */

#ifndef _BSD_SOURCE
#define _BSD_SOURCE
#endif

#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE		500
#endif

#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE		200112L
#endif

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <limits.h>

#ifndef SYMLOOP_MAX
#define SYMLOOP_MAX 8
#endif

#define INTERNAL_PATH_MAX		1024

#define strlcat		internal_strlcat
#define strlcpy		internal_strlcpy

#define realpath		internal_realpath
