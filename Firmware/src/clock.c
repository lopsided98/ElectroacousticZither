#include <xtmrctr.h>
#include <xparameters.h>
#include "clock.h"

#define CLOCK_TIMER_DEVICE_ID XPAR_TIMER_DEVICE_ID
#define CLOCK_TIMER_FREQ XPAR_TIMER_CLOCK_FREQ_HZ
#define CLOCK_TIMER_COUNTER_NUMBER 0

#define CLOCK_TICKS_PER_US XTC_ROUND_DIV(CLOCK_TIMER_FREQ, 1000000)
#define CLOCK_TICKS_PER_MS XTC_ROUND_DIV(CLOCK_TIMER_FREQ, 1000)

static XTmrCtr clock_timer;

int clock_init() {
	int err;
	err = XTmrCtr_Initialize(&clock_timer, CLOCK_TIMER_DEVICE_ID);
	if (err) return err;

	err = XTmrCtr_SelfTest(&clock_timer, CLOCK_TIMER_COUNTER_NUMBER);
	if (err) return err;

	// Automatic wrapping
	XTmrCtr_SetOptions(&clock_timer, CLOCK_TIMER_COUNTER_NUMBER, XTC_AUTO_RELOAD_OPTION);

	XTmrCtr_Start(&clock_timer, CLOCK_TIMER_COUNTER_NUMBER);

	return XST_SUCCESS;
}

uint32_t clock_ticks() {
	return XTmrCtr_GetValue(&clock_timer, CLOCK_TIMER_COUNTER_NUMBER);
}

uint32_t clock_us() {
	return clock_ticks() / CLOCK_TICKS_PER_US;
}

uint32_t clock_ms() {
	return clock_ticks() / CLOCK_TICKS_PER_MS;
}
