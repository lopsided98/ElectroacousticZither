#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include "util.h"

// Convert a frequency in mHz to a period in clock cycles
#define STRING_PERIOD(f) DIV_ROUND_CLOSEST(XPAR_CPU_CORE_CLOCK_FREQ_HZ * 100UL, (f))

#define STRING_DRIVER_MAX_AMPLITUDE 1000

#define STRING_DRIVER_PERIOD_OFFSET 0
#define STRING_DRIVER_AMPLITUDE_OFFSET 4
#define STRING_DRIVER_FLAGS_OFFSET 8


struct string_driver {
	size_t base_addr;
};

void string_driver_init(const struct string_driver *s);

void string_driver_set_period(const struct string_driver *s, uint32_t period);

void string_driver_set_amplitude(const struct string_driver *s, uint32_t amplitude);

void string_driver_set_inverted(const struct string_driver *s, bool inverted);
