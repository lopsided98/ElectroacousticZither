#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <xuartns550.h>

#define MIDI_MAX_DATA_BYTES 3

#define MIDI_TYPE_MASK 0x80
#define MIDI_STATUS_COMMAND_MASK 0xF0
#define MIDI_STATUS_CHANNEL_MASK 0x0F

#define MIDI_PITCH_BEND_CENTER 8192

enum midi_status_type {
	MIDI_STATUS_TYPE_VOICE,
	MIDI_STATUS_TYPE_SYSTEM_COMMON,
	MIDI_STATUS_TYPE_SYSTEM_REAL_TIME
};

enum midi_command {
	MIDI_COMMAND_INVALID = 0x00,
	MIDI_COMMAND_NOTE_OFF = 0x80,
	MIDI_COMMAND_NOTE_ON = 0x90,
	MIDI_COMMAND_POLYPHONIC_PRESSURE = 0xA0,
	MIDI_COMMAND_CONTROL_CHANGE = 0xB0,
	MIDI_COMMAND_PROGRAM_CHANGE = 0xC0,
	MIDI_COMMAND_CHANNEL_PRESSURE = 0xD0,
	MIDI_COMMAND_PITCH_BEND = 0xE0,
	MIDI_COMMAND_SYSTEM = 0xF0
};

enum midi_command_system {
	MIDI_COMMAND_SYSTEM_EXCLUSIVE = 0xF0,
	MIDI_COMMAND_SYSTEM_TIME_CODE_QUARTER_FRAME = 0xF1,
	MIDI_COMMAND_SYSTEM_SONG_POSITON = 0xF2,
	MIDI_COMMAND_SYSTEM_SONG_SELECT = 0xF3,
	MIDI_COMMAND_SYSTEM_TUNE_REQUEST = 0xF6,
	MIDI_COMMAND_SYSTEM_END_OF_EXCLUSIVE = 0xF7,
	MIDI_COMMAND_SYSTEM_TIMING_CLOCK = 0xF8,
	MIDI_COMMAND_SYSTEM_START = 0xFA,
	MIDI_COMMAND_SYSTEM_CONTINUE = 0xFB,
	MIDI_COMMAND_SYSTEM_STOP = 0xFC,
	MIDI_COMMAND_SYSTEM_ACTIVE_SENSE = 0xFE,
	MIDI_COMMAND_SYSTEM_RESET = 0xFF,
};

enum midi_note {
	MIDI_NOTE_C2 = 36,
	MIDI_NOTE_D2 = 38,
	MIDI_NOTE_E2 = 40,
	MIDI_NOTE_F2 = 41,
	MIDI_NOTE_G2 = 43,
	MIDI_NOTE_A2 = 45,
	MIDI_NOTE_B2 = 47,
	MIDI_NOTE_C3 = 48,
	MIDI_NOTE_D3 = 50,
	MIDI_NOTE_E3 = 52,
	MIDI_NOTE_F3 = 53,
	MIDI_NOTE_G3 = 55,
	MIDI_NOTE_A3 = 57,
	MIDI_NOTE_B3 = 59,
	MIDI_NOTE_C4 = 60,
	MIDI_NOTE_D4 = 62,
	MIDI_NOTE_A4 = 69,
	MIDI_NOTE_B4 = 71,
	MIDI_NOTE_C5 = 72,
	MIDI_NOTE_D5 = 74,
	MIDI_NOTE_E5 = 76,
	MIDI_NOTE_F5 = 77,
	MIDI_NOTE_G5 = 79,
	MIDI_NOTE_A5 = 81,
	MIDI_NOTE_B5 = 83
};

struct midi {
	XUartNs550 *uart;
	uint8_t status;
	uint8_t running_status;
	uint8_t remaining_data_bytes;
};

struct midi_msg {
	uint8_t status;
	uint8_t data[MIDI_MAX_DATA_BYTES];
};

void midi_init(struct midi *m, XUartNs550 *uart);

bool midi_recv(struct midi *m, struct midi_msg *msg);

uint8_t midi_msg_command(const struct midi_msg* msg);

uint8_t midi_msg_note(const struct midi_msg* msg);

int16_t midi_msg_pitch_bend(const struct midi_msg* msg);
