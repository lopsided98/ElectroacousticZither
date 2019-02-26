#include <xil_io.h>
#include "string_driver.h"

void string_driver_init(const struct string_driver *s) {
}

void string_driver_set_period(const struct string_driver *s, uint32_t period) {
	Xil_Out32(s->base_addr + STRING_DRIVER_PERIOD_OFFSET, period);
}

void string_driver_set_amplitude(const struct string_driver *s, uint32_t amplitude) {
	Xil_Out32(s->base_addr + STRING_DRIVER_AMPLITUDE_OFFSET, amplitude);
}

void string_driver_set_inverted(const struct string_driver *s, bool inverted) {
	Xil_Out32(s->base_addr + STRING_DRIVER_FLAGS_OFFSET, inverted ? 0x1 : 0x0);
}
