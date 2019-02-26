#include <stdio.h>
#include <stdint.h>
#include <xparameters.h>
#include <xgpio.h>
#include <xuartns550.h>
#include <sleep.h>

#include "util.h"
#include "clock.h"
#include "string_driver.h"
#include "note_controller.h"
#include "midi.h"

enum midi_note_string {
	MIDI_NOTE_STRING_C3 = 0,
	MIDI_NOTE_STRING_G3 = 1,
	MIDI_NOTE_STRING_D4 = 2,
	MIDI_NOTE_STRING_A4 = 3,
	MIDI_NOTE_STRING_C4 = 0,
	MIDI_NOTE_STRING_G4 = 1,
	MIDI_NOTE_STRING_D5 = 2,
	MIDI_NOTE_STRING_A5 = 3
};

#define PERIOD(f) DIV_ROUND_CLOSEST(XPAR_CPU_CORE_CLOCK_FREQ_HZ * 100UL, (f))

enum midi_note_period {
	MIDI_NOTE_PERIOD_C3 = PERIOD(13081), // C3
	MIDI_NOTE_PERIOD_G3 = PERIOD(19600), // G3
	MIDI_NOTE_PERIOD_D4 = PERIOD(29366), // D4
	MIDI_NOTE_PERIOD_A4 = PERIOD(44000), // A4
	MIDI_NOTE_PERIOD_C4 = PERIOD(26163), // C4
	MIDI_NOTE_PERIOD_G4 = PERIOD(39200), // G4
	MIDI_NOTE_PERIOD_D5 = PERIOD(58733), // D5
	MIDI_NOTE_PERIOD_A5 = PERIOD(88000) // A5
};

static struct string_driver strings[8] = { { .base_addr =
XPAR_STRING_0_BASEADDR }, { .base_addr = XPAR_STRING_1_BASEADDR }, {
		.base_addr = XPAR_STRING_2_BASEADDR }, { .base_addr =
XPAR_STRING_3_BASEADDR }, { .base_addr = XPAR_STRING_4_BASEADDR }, {
		.base_addr = XPAR_STRING_5_BASEADDR }, { .base_addr =
XPAR_STRING_6_BASEADDR }, { .base_addr = XPAR_STRING_7_BASEADDR } };

static struct note_controller controllers[8];

#define GPIO_LEDS_CHANNEL 1
#define GPIO_SWITCHES_CHANNEL 2
static XGpio leds_switches;

static XUartNs550Format usb_uart_data_format = { .BaudRate = 115200, .DataBits =
XUN_FORMAT_8_BITS, .StopBits = XUN_FORMAT_1_STOP_BIT, .Parity =
XUN_FORMAT_NO_PARITY };
static XUartNs550 usb_uart;

static XUartNs550Format midi_uart_data_format = { .BaudRate = 31250, .DataBits =
XUN_FORMAT_8_BITS, .StopBits = XUN_FORMAT_1_STOP_BIT, .Parity =
XUN_FORMAT_NO_PARITY };
static XUartNs550 midi_uart;

static struct midi midi;

int init() {
	int err = XST_SUCCESS;
	if ((err = clock_init()))
		return err;

	// LEDs and switches GPIO
	if ((err = XGpio_Initialize(&leds_switches, XPAR_LEDS_SWITCHES_DEVICE_ID)))
		return err;
	if ((err = XGpio_SelfTest(&leds_switches)))
		return err;
	XGpio_SetDataDirection(&leds_switches, GPIO_LEDS_CHANNEL, 0x0000);
	XGpio_SetDataDirection(&leds_switches, GPIO_SWITCHES_CHANNEL, 0xFFFF);

	// USB UART
	if ((err = XUartNs550_Initialize(&usb_uart, XPAR_UART_DEVICE_ID)))
		return err;
	if ((err = XUartNs550_SelfTest(&usb_uart)))
		return err;
	if ((err = XUartNs550_SetDataFormat(&usb_uart, &usb_uart_data_format)))
		return err;

	// MIDI UART
	if ((err = XUartNs550_Initialize(&midi_uart, XPAR_MIDI_UART_DEVICE_ID)))
		return err;
	if ((err = XUartNs550_SelfTest(&midi_uart)))
		return err;
	if ((err = XUartNs550_SetDataFormat(&midi_uart, &midi_uart_data_format)))
		return err;

	// Strings
	for (size_t i = 0; i < 8; ++i) {
		string_driver_init(&strings[i]);
		note_controller_init(&controllers[i], &strings[i]);
	}

	// MIDI controller
	midi_init(&midi, &midi_uart);

	return err;
}

size_t midi_note_string(uint8_t note) {
	switch (note) {
	case MIDI_NOTE_C2:
		return MIDI_NOTE_STRING_C3;
	case MIDI_NOTE_D2:
		return MIDI_NOTE_STRING_G3;
	case MIDI_NOTE_E2:
		return MIDI_NOTE_STRING_D4;
	case MIDI_NOTE_F2:
		return MIDI_NOTE_STRING_A4;
	case MIDI_NOTE_G2:
		return MIDI_NOTE_STRING_C4;
	case MIDI_NOTE_A2:
		return MIDI_NOTE_STRING_G4;
	case MIDI_NOTE_B2:
		return MIDI_NOTE_STRING_D5;
	case MIDI_NOTE_C3:
		return MIDI_NOTE_STRING_A5;
	default:
		return SIZE_MAX;
	}
}

uint32_t midi_note_period(uint8_t note) {
	switch (note) {
	case MIDI_NOTE_C2:
		return MIDI_NOTE_PERIOD_C3;
	case MIDI_NOTE_D2:
		return MIDI_NOTE_PERIOD_G3;
	case MIDI_NOTE_E2:
		return MIDI_NOTE_PERIOD_D4;
	case MIDI_NOTE_F2:
		return MIDI_NOTE_PERIOD_A4;
	case MIDI_NOTE_G2:
		return MIDI_NOTE_PERIOD_C4;
	case MIDI_NOTE_A2:
		return MIDI_NOTE_PERIOD_G4;
	case MIDI_NOTE_B2:
		return MIDI_NOTE_PERIOD_D5;
	case MIDI_NOTE_C3:
		return MIDI_NOTE_PERIOD_A5;
	default:
		return 0xFFFF;
	}
}

void handle_midi_msg(struct midi_msg *msg) {
	uint8_t command = midi_msg_command(msg);

	struct note_controller *controller = NULL;

	switch (command) {
	case MIDI_COMMAND_NOTE_ON:
		printf("note: %u\n", midi_msg_note(msg));
	case MIDI_COMMAND_NOTE_OFF: {
		uint8_t note = midi_msg_note(msg);
		size_t i = midi_note_string(note);
		if (i < ARRAY_LENGTH(controllers)) {
			controller = &controllers[i];
			note_controller_set_period(controller, midi_note_period(note));
		}
	}
		break;
	default:
		printf("command: %u: %u = %u\n", command, msg->data[0], msg->data[1]);
		break;
	}

	if (controller) {
		switch (command) {
		case MIDI_COMMAND_NOTE_ON:
			print("note on\n");
			note_controller_start(controller);
			break;
		case MIDI_COMMAND_NOTE_OFF:
			print("note off\n");
			note_controller_stop(controller);
			break;
		}
	}
}

int main() {
	int err = XST_SUCCESS;

	if ((err = init())) {
		printf("Initialization failed, error: %d\n", err);
		return err;
	}

	print("Started\n");

	struct midi_msg midi_msg;

	uint32_t old_switches = 0;

	while (true) {

		if (midi_recv(&midi, &midi_msg)) {
			handle_midi_msg(&midi_msg);
		}

		uint32_t switches = XGpio_DiscreteRead(&leds_switches,
		GPIO_SWITCHES_CHANNEL);
		uint32_t changed_switches = switches ^ old_switches;
		old_switches = switches;

		XGpio_DiscreteWrite(&leds_switches, GPIO_LEDS_CHANNEL, switches);

		for (uint8_t i = 0; i < 8; ++i) {
			if (changed_switches & switches & (1 << i)) {
				note_controller_start(&controllers[i]);
			}
			if (changed_switches & ~switches & (1 << i)) {
				note_controller_stop(&controllers[i]);
			}
			note_controller_update(&controllers[i]);
		}
		usleep(20);
	}
	return 0;
}
