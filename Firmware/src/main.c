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

static struct string_driver strings[8] = {
	{ .base_addr = XPAR_STRING_0_BASEADDR },
	{ .base_addr = XPAR_STRING_1_BASEADDR },
	{ .base_addr = XPAR_STRING_2_BASEADDR },
	{ .base_addr = XPAR_STRING_3_BASEADDR },
	{ .base_addr = XPAR_STRING_4_BASEADDR },
	{ .base_addr = XPAR_STRING_5_BASEADDR },
	{ .base_addr = XPAR_STRING_6_BASEADDR },
	{ .base_addr = XPAR_STRING_7_BASEADDR }
};

static struct note_controller controllers[8];

struct note_config {
	struct note_controller *controller;
	struct note_controller_config controller_config;
};

const struct note_config NOTE_CONFIG_F3 = {
	.controller = &controllers[0],
	.controller_config = {
		.period = STRING_PERIOD(17461),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_G3 = {
	.controller = &controllers[1],
	.controller_config = {
		.period = STRING_PERIOD(19600),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_A3 = {
	.controller = &controllers[2],
	.controller_config = {
		.period = STRING_PERIOD(22000),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_B3_FLAT = {
	.controller = &controllers[3],
	.controller_config = {
		.period = STRING_PERIOD(23308),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_C4 = {
	.controller = &controllers[4],
	.controller_config = {
		.period = STRING_PERIOD(26163),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_D4 = {
	.controller = &controllers[5],
	.controller_config = {
		.period = STRING_PERIOD(29366),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_E4 = {
	.controller = &controllers[6],
	.controller_config = {
		.period = STRING_PERIOD(32963),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_F4 = {
	.controller = &controllers[7],
	.controller_config = {
		.period = STRING_PERIOD(34923),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_F4_2 = {
	.controller = &controllers[0],
	.controller_config = {
		.period = STRING_PERIOD(34923),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_G4 = {
	.controller = &controllers[1],
	.controller_config = {
		.period = STRING_PERIOD(39200),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_A4 = {
	.controller = &controllers[2],
	.controller_config = {
		.period = STRING_PERIOD(44000),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_B4_FLAT = {
	.controller = &controllers[3],
	.controller_config = {
		.period = STRING_PERIOD(46616),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_C5 = {
	.controller = &controllers[4],
	.controller_config = {
		.period = STRING_PERIOD(52325),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_D5 = {
	.controller = &controllers[5],
	.controller_config = {
		.period = STRING_PERIOD(58733),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_E5 = {
	.controller = &controllers[6],
	.controller_config = {
		.period = STRING_PERIOD(65926),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

const struct note_config NOTE_CONFIG_F5 = {
	.controller = &controllers[7],
	.controller_config = {
		.period = STRING_PERIOD(69846),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000UL,
		.release_time = 15000,
	}
};

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
	for (size_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
		string_driver_init(&strings[i]);
		note_controller_init(&controllers[i], &strings[i]);
	}

	// MIDI controller
	midi_init(&midi, &midi_uart);

	return err;
}

const struct note_config *midi_note_config(uint8_t note) {
	switch (note) {
	case MIDI_NOTE_C2:
		return &NOTE_CONFIG_F3;
	case MIDI_NOTE_D2:
		return &NOTE_CONFIG_G3;
	case MIDI_NOTE_E2:
		return &NOTE_CONFIG_A3;
	case MIDI_NOTE_F2:
		return &NOTE_CONFIG_B3_FLAT;
	case MIDI_NOTE_G2:
		return &NOTE_CONFIG_C4;
	case MIDI_NOTE_A2:
		return &NOTE_CONFIG_D4;
	case MIDI_NOTE_B2:
		return &NOTE_CONFIG_E4;
	case MIDI_NOTE_C3:
		return &NOTE_CONFIG_F4;
	case MIDI_NOTE_D3:
		return &NOTE_CONFIG_G4;
	case MIDI_NOTE_E3:
		return &NOTE_CONFIG_A4;
	case MIDI_NOTE_F3:
		return &NOTE_CONFIG_B4_FLAT;
	case MIDI_NOTE_G3:
		return &NOTE_CONFIG_C5;
	case MIDI_NOTE_A3:
		return &NOTE_CONFIG_D5;
	case MIDI_NOTE_B3:
		return &NOTE_CONFIG_E5;
	case MIDI_NOTE_C4:
		return &NOTE_CONFIG_F5;
	default:
		return NULL;
	}
}

void handle_midi_msg(const struct midi_msg *msg) {
	uint8_t command = midi_msg_command(msg);

	const struct note_config *config = NULL;

	switch (command) {
	case MIDI_COMMAND_NOTE_ON:
		printf("note: %u\n", midi_msg_note(msg));
	case MIDI_COMMAND_NOTE_OFF:
		config = midi_note_config(midi_msg_note(msg));
		break;
	case MIDI_COMMAND_PITCH_BEND:
		for (uint8_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
			note_controller_pitch_bend(&controllers[i], midi_msg_pitch_bend(msg));
		}
		break;
	default:
		printf("command: %u: %u = %u\n", command, msg->data[0], msg->data[1]);
		break;
	}

	if (config) {
		note_controller_set_config(config->controller, &config->controller_config);

		switch (command) {
		case MIDI_COMMAND_NOTE_ON:
			note_controller_start(config->controller);
			break;
		case MIDI_COMMAND_NOTE_OFF:
			note_controller_stop(config->controller);
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

		for (uint8_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
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

	return err;
}
