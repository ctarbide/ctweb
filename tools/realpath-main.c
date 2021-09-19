
#include "config.h"
#include "protos.h"

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
