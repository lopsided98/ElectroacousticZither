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

static struct note_config NOTE_CONFIG_F3 = {
	.controller = &controllers[0],
	.controller_config = {
		.period = STRING_PERIOD(17461),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 70000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_G3 = {
	.controller = &controllers[1],
	.controller_config = {
		.period = STRING_PERIOD(19600),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_A3 = {
	.controller = &controllers[2],
	.controller_config = {
		.period = STRING_PERIOD(22000),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_B3_FLAT = {
	.controller = &controllers[3],
	.controller_config = {
		.period = STRING_PERIOD(23308),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_C4 = {
	.controller = &controllers[4],
	.controller_config = {
		.period = STRING_PERIOD(26163),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_D4 = {
	.controller = &controllers[5],
	.controller_config = {
		.period = STRING_PERIOD(29366),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 1500
	}
};

static struct note_config NOTE_CONFIG_E4 = {
	.controller = &controllers[6],
	.controller_config = {
		.period = STRING_PERIOD(32963),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 1500
	}
};

static struct note_config NOTE_CONFIG_F4 = {
	.controller = &controllers[7],
	.controller_config = {
		.period = STRING_PERIOD(34923),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 1500
	}
};

static struct note_config NOTE_CONFIG_F4_2 = {
	.controller = &controllers[0],
	.controller_config = {
		.period = STRING_PERIOD(34923),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_G4 = {
	.controller = &controllers[1],
	.controller_config = {
		.period = STRING_PERIOD(39200),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_A4 = {
	.controller = &controllers[2],
	.controller_config = {
		.period = STRING_PERIOD(44000),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

static struct note_config NOTE_CONFIG_B4_FLAT = {
	.controller = &controllers[3],
	.controller_config = {
		.period = STRING_PERIOD(46616),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000,
	}
};

static struct note_config NOTE_CONFIG_C5 = {
	.controller = &controllers[4],
	.controller_config = {
		.period = STRING_PERIOD(52325),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_D5 = {
	.controller = &controllers[5],
	.controller_config = {
		.period = STRING_PERIOD(58733),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_E5 = {
	.controller = &controllers[6],
	.controller_config = {
		.period = STRING_PERIOD(65926),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

static struct note_config NOTE_CONFIG_F5 = {
	.controller = &controllers[7],
	.controller_config = {
		.period = STRING_PERIOD(69846),
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000,
		.release_time = 15000
	}
};

#define GPIO_LEDS_CHANNEL 1
#define GPIO_SWITCHES_CHANNEL 2

#define GPIO_SWITCHES_REMAP_MASK 0x8000
#define GPIO_SWITCHES_STRING_MASK 0x00FF

static XGpio leds_switches;

static XUartNs550Format usb_uart_data_format = {
	.BaudRate = 115200,
	.DataBits = XUN_FORMAT_8_BITS,
	.StopBits = XUN_FORMAT_1_STOP_BIT,
	.Parity = XUN_FORMAT_NO_PARITY
};
static XUartNs550 usb_uart;

static XUartNs550Format midi_uart_data_format = {
	.BaudRate = 31250,
	.DataBits = XUN_FORMAT_8_BITS,
	.StopBits = XUN_FORMAT_1_STOP_BIT,
	.Parity = XUN_FORMAT_NO_PARITY
};
static XUartNs550 midi_uart;

static XUartNs550Format debug_uart_data_format = {
	.BaudRate = 115200,
	.DataBits = XUN_FORMAT_8_BITS,
	.StopBits = XUN_FORMAT_1_STOP_BIT,
	.Parity = XUN_FORMAT_NO_PARITY
};
static XUartNs550 debug_uart;

static struct midi midi;
static struct midi usb_midi;

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

	// Debug UART
	if ((err = XUartNs550_Initialize(&debug_uart, XPAR_DEBUG_UART_DEVICE_ID)))
		return err;
	if ((err = XUartNs550_SelfTest(&debug_uart)))
		return err;
	if ((err = XUartNs550_SetDataFormat(&debug_uart, &debug_uart_data_format)))
		return err;

	// Strings
	for (size_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
		string_driver_init(&strings[i]);
		note_controller_init(&controllers[i], &strings[i]);
	}

	// MIDI controller
	midi_init(&midi, &midi_uart);

	// USB MIDI controller
	midi_init(&usb_midi, &usb_uart);

	return err;
}

enum midi_note midi_note_keyboard_remap(enum midi_note note) {
	switch (note) {
	case MIDI_NOTE_C2:
		return MIDI_NOTE_F3;
	case MIDI_NOTE_D2:
		return MIDI_NOTE_G3;
	case MIDI_NOTE_E2:
		return MIDI_NOTE_A3;
	case MIDI_NOTE_F2:
		return MIDI_NOTE_B3_FLAT;
	case MIDI_NOTE_G2:
		return MIDI_NOTE_C4;
	case MIDI_NOTE_A2:
		return MIDI_NOTE_D4;
	case MIDI_NOTE_B2:
		return MIDI_NOTE_E4;
	case MIDI_NOTE_C3:
		return MIDI_NOTE_F4;
	case MIDI_NOTE_D3:
		return MIDI_NOTE_G4;
	case MIDI_NOTE_E3:
		return MIDI_NOTE_A4;
	case MIDI_NOTE_F3:
		return MIDI_NOTE_B4_FLAT;
	case MIDI_NOTE_G3:
		return MIDI_NOTE_C5;
	case MIDI_NOTE_A3:
		return MIDI_NOTE_D5;
	case MIDI_NOTE_B3:
		return MIDI_NOTE_E5;
	case MIDI_NOTE_C4:
		return MIDI_NOTE_F5;
	default:
		return MIDI_NOTE_INVALID;
	}
}

struct note_config *midi_note_config_harmonic(uint8_t note) {
	switch (note) {
	case MIDI_NOTE_F3:
		return &NOTE_CONFIG_F4_2;
	case MIDI_NOTE_G3:
		return &NOTE_CONFIG_G4;
	case MIDI_NOTE_A3:
		return &NOTE_CONFIG_A4;
	case MIDI_NOTE_B3_FLAT:
		return &NOTE_CONFIG_B4_FLAT;
	case MIDI_NOTE_C4:
		return &NOTE_CONFIG_C5;
	case MIDI_NOTE_D4:
		return &NOTE_CONFIG_D5;
	case MIDI_NOTE_E4:
		return &NOTE_CONFIG_E5;
	case MIDI_NOTE_F4:
		return &NOTE_CONFIG_F5;
	default:
		return NULL;
	}
}

struct note_config *midi_note_config(uint8_t note) {
	switch (note) {
	case MIDI_NOTE_F3:
		return &NOTE_CONFIG_F3;
	case MIDI_NOTE_G3:
		return &NOTE_CONFIG_G3;
	case MIDI_NOTE_A3:
		return &NOTE_CONFIG_A3;
	case MIDI_NOTE_B3_FLAT:
		return &NOTE_CONFIG_B3_FLAT;
	case MIDI_NOTE_C4:
		return &NOTE_CONFIG_C4;
	case MIDI_NOTE_D4:
		return &NOTE_CONFIG_D4;
	case MIDI_NOTE_E4:
		return &NOTE_CONFIG_E4;
	case MIDI_NOTE_F4:
		return &NOTE_CONFIG_F4;
	case MIDI_NOTE_G4:
		return &NOTE_CONFIG_G4;
	case MIDI_NOTE_A4:
		return &NOTE_CONFIG_A4;
	case MIDI_NOTE_B4_FLAT:
		return &NOTE_CONFIG_B4_FLAT;
	case MIDI_NOTE_C5:
		return &NOTE_CONFIG_C5;
	case MIDI_NOTE_D5:
		return &NOTE_CONFIG_D5;
	case MIDI_NOTE_E5:
		return &NOTE_CONFIG_E5;
	case MIDI_NOTE_F5:
		return &NOTE_CONFIG_F5;
	default:
		return NULL;
	}
}

void handle_midi_note_on(const struct midi_msg *msg, bool remap) {
	enum midi_note note = midi_msg_note(msg);
	uint8_t velocity = midi_msg_velocity(msg);
	if (remap) {
		note = midi_note_keyboard_remap(note);
	}
	struct note_config *config = midi_note_config(note);
	printf("note on: %u, velocity: %u", note, velocity);
	if (config) {
		putchar('\n');
		note_controller_set_config(config->controller, &config->controller_config);
		if (velocity != 0) {
			note_controller_start(config->controller);
		} else {
			note_controller_stop(config->controller);
		}
	} else {
		puts(" (out of range)");
	}
}

void handle_midi_note_off(const struct midi_msg *msg, bool remap) {
	enum midi_note note = midi_msg_note(msg);
	if (remap) {
		note = midi_note_keyboard_remap(note);
	}
	struct note_config *config = midi_note_config(note);
	if (config) {
		note_controller_stop(config->controller);
	}
}

void handle_midi_control_change(const struct midi_msg *msg) {
	switch (midi_msg_control(msg)) {
	case MIDI_CONTROL_ALL_SOUND_OFF:
	case MIDI_CONTROL_ALL_NOTES_OFF:
		for (uint8_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
			note_controller_stop(&controllers[i]);
		}
		break;
	}
}

void handle_midi_sysex_frequency(const struct midi_msg *msg) {
	enum midi_note note = midi_msg_note(msg);
	struct note_config *config = midi_note_config(note);

	uint32_t frequency = midi_msg_sysex_freqency(msg);
	printf("note: %u, frequency: %lu\n", midi_msg_note(msg), frequency);

	if (frequency && config) {
		config->controller_config.period = STRING_PERIOD(frequency);
		note_controller_set_config(config->controller, &config->controller_config);

		struct note_config *harmonic_config = midi_note_config_harmonic(note);
		if (harmonic_config) {
			harmonic_config->controller_config.period = DIV_ROUND_CLOSEST(config->controller_config.period, 2);
		}
	}
}

void handle_midi_msg(const struct midi_msg *msg, bool remap) {
	uint8_t command = midi_msg_command(msg);

	switch (command) {
	case MIDI_COMMAND_NOTE_OFF:
		handle_midi_note_off(msg, remap);
		break;
	case MIDI_COMMAND_NOTE_ON:
		handle_midi_note_on(msg, remap);
		break;
	case MIDI_COMMAND_CONTROL_CHANGE:
		handle_midi_control_change(msg);
		break;
	case MIDI_COMMAND_PITCH_BEND:
//		for (uint8_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
//			note_controller_pitch_bend(&controllers[i], midi_msg_pitch_bend(msg));
//		}
		break;
	case MIDI_COMMAND_SYSTEM:
		switch (msg->status) {
		case MIDI_COMMAND_SYSTEM_EXCLUSIVE:
			switch (midi_msg_command_sysex(msg)) {
			case MIDI_COMMAND_SYSEX_FREQENCY:
				handle_midi_sysex_frequency(msg);
				break;
			}
			break;
		}
		break;
	default:
		printf("command: %u: %u = %u\n", command, msg->data[0], msg->data[1]);
		break;
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
	struct midi_msg usb_midi_msg;

	uint32_t old_switches = 0;

	while (true) {
		uint32_t leds = 0;

		uint32_t switches = XGpio_DiscreteRead(&leds_switches, GPIO_SWITCHES_CHANNEL);
		uint32_t changed_switches = switches ^ old_switches;
		old_switches = switches;

		// Whether to enable keyboard remap
		leds |= switches & GPIO_SWITCHES_REMAP_MASK;
		bool remap = (switches & GPIO_SWITCHES_REMAP_MASK) != 0;

		if (midi_recv(&midi, &midi_msg)) {
			handle_midi_msg(&midi_msg, remap);
		}

		if (midi_recv(&usb_midi, &usb_midi_msg)) {
			// USB MIDI never uses keyboard remap
			handle_midi_msg(&usb_midi_msg, false);
		}

		for (uint8_t i = 0; i < ARRAY_LENGTH(controllers); ++i) {
			struct note_controller *controller = &controllers[i];

			if (changed_switches & switches & (1 << i)) {
				note_controller_start(controller);
			}
			if (changed_switches & ~switches & (1 << i)) {
				note_controller_stop(controller);
			}
			note_controller_update(controller);

			if (note_controller_is_started(controller)) {
				leds |= 1 << i;
			}
		}

		XGpio_DiscreteWrite(&leds_switches, GPIO_LEDS_CHANNEL, leds);

		usleep(20);
	}

	return err;
}
