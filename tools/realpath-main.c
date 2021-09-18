
/* TODO: decide how to differentiate primary dependencies with and without
 * source concatenation in the build system

#include "config.h"
#include "protos.h"
 */

int main(int argc, char **argv)
{
	char resolved[INTERNAL_PATH_MAX];
	while (*++argv) {
		char *res;
		res = realpath(*argv, resolved);
		if (res)
			puts(res);
	}
	return 0;
}
