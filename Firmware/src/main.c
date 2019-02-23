#include <stdio.h>
#include <stdint.h>
#include <xparameters.h>
#include <xgpio.h>
#include <sleep.h>

#include "string_driver.h"
#include "note_controller.h"

static const uint32_t periods[8] = {
	191117, // C3, 130.8099 Hz
	127551, // G3, 196.0000 Hz
	85132, // D4, 293.6616 Hz
	56818, // A4, 440.0014 Hz
	56818, // A4, 440.0014 Hz
	56818, // A4, 440.0014 Hz
	56818, // A4, 440.0014 Hz
	56818 // A4, 440.0014 Hz
};

static const struct string_driver strings[8] = {
	{.base_addr = XPAR_STRING_0_BASEADDR},
	{.base_addr = XPAR_STRING_1_BASEADDR},
	{.base_addr = XPAR_STRING_2_BASEADDR},
	{.base_addr = XPAR_STRING_3_BASEADDR},
	{.base_addr = XPAR_STRING_4_BASEADDR},
	{.base_addr = XPAR_STRING_5_BASEADDR},
	{.base_addr = XPAR_STRING_6_BASEADDR},
	{.base_addr = XPAR_STRING_7_BASEADDR}
};

static struct note_controller controllers[8];

#define ATTACK_AMPLITUDE 1000
#define SUSTAIN_AMPLITUDE 417

#define GPIO_LEDS_CHANNEL 1
#define GPIO_SWITCHES_CHANNEL 2
static XGpio leds_switches;

void init() {
	XGpio_Initialize(&leds_switches, XPAR_LEDS_SWITCHES_DEVICE_ID);
    XGpio_SetDataDirection(&leds_switches, GPIO_LEDS_CHANNEL, 0x0000);
    XGpio_SetDataDirection(&leds_switches, GPIO_SWITCHES_CHANNEL, 0xFFFF);

    for (size_t i = 0; i < 8; ++i) {
		note_controller_init(&controllers[i], &strings[i]);
	}
}

int main() {
	print("Starting...\n");

	init();

    while(true) {
		uint32_t switches = XGpio_DiscreteRead(&leds_switches, GPIO_SWITCHES_CHANNEL);
		XGpio_DiscreteWrite(&leds_switches, GPIO_LEDS_CHANNEL, switches);
		for (uint8_t i = 0; i < 8; ++i) {
			if (switches & (1 << i)) {
				string_driver_set_amplitude(&strings[i], SUSTAIN_AMPLITUDE);
			} else {
				string_driver_set_amplitude(&strings[i], 0);
			}
		}
		usleep(50000);
    }
	return 0;
}
