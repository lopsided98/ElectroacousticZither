#include "util.h"
#include <stdio.h>

#ifndef NDEBUG

void _assert(const char *file, uint32_t line, bool f) {
	if (!f) {
		printf("%s:%lu: assertion failed\n", file, line);
	}
}

#endif
