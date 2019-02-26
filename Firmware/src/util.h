#pragma once
#include <stdint.h>
#include <stdbool.h>

#define ARRAY_LENGTH(array) (sizeof((array))/sizeof((array)[0]))

#define DIV_ROUND_CLOSEST(dividend, divisor) (((dividend) + ((divisor) / 2)) / (divisor))

#ifndef NDEBUG

#define ASSERT(f) _assert(__FILE__, __LINE__, f)

#else

#define ASSERT(f) (f)

#endif


void _assert(const char *file, uint32_t line, bool f);
