#include "midi.h"
#include "util.h"

void midi_init(struct midi *m, XUartNs550 *uart) {
	m->uart = uart;
	m->running_status = MIDI_COMMAND_INVALID;
	m->remaining_data_bytes = 0;
}

static enum midi_status_type midi_status_type(uint8_t status) {
	switch (status & 0xF8) {
	default:
		return MIDI_STATUS_TYPE_VOICE;
	case 0xF0:
		return MIDI_STATUS_TYPE_SYSTEM_COMMON;
	case 0xF8:
		return MIDI_STATUS_TYPE_SYSTEM_REAL_TIME;
	}
}

static int8_t midi_data_bytes(uint8_t status) {
	switch (status & MIDI_STATUS_COMMAND_MASK) {
	case MIDI_COMMAND_PROGRAM_CHANGE:
	case MIDI_COMMAND_CHANNEL_PRESSURE:
		return 1;
	case MIDI_COMMAND_NOTE_OFF:
	case MIDI_COMMAND_NOTE_ON:
	case MIDI_COMMAND_POLYPHONIC_PRESSURE:
	case MIDI_COMMAND_CONTROL_CHANGE:
	case MIDI_COMMAND_PITCH_BEND:
		return 2;
	case MIDI_COMMAND_SYSTEM:
		switch (status) {
		case MIDI_COMMAND_SYSTEM_TUNE_REQUEST:
		case MIDI_COMMAND_SYSTEM_TIMING_CLOCK:
		case MIDI_COMMAND_SYSTEM_START:
		case MIDI_COMMAND_SYSTEM_STOP:
		case MIDI_COMMAND_SYSTEM_ACTIVE_SENSE:
		case MIDI_COMMAND_SYSTEM_RESET:
			return 0;
		case MIDI_COMMAND_SYSTEM_TIME_CODE_QUARTER_FRAME:
		case MIDI_COMMAND_SYSTEM_SONG_SELECT:
			return 1;
		case MIDI_COMMAND_SYSTEM_SONG_POSITON:
			return 2;
		case MIDI_COMMAND_SYSTEM_EXCLUSIVE:
			// We only return a limited number of SysEx data bytes
			return MIDI_MAX_DATA_BYTES;
		default:
			return -1;
		}
	default:
		return -1;
	}
}

bool midi_recv(struct midi *m, struct midi_msg* msg) {
	uint8_t data;
	unsigned int n = XUartNs550_Recv(m->uart, &data, 1);
	if (!n) {
		return false;
	}

	if (data & MIDI_TYPE_MASK) {
		// Status byte
		switch (midi_status_type(data)) {
		case MIDI_STATUS_TYPE_VOICE:
			m->running_status = data;
			break;
		case MIDI_STATUS_TYPE_SYSTEM_COMMON:
			// System Common messages clear running status
			m->running_status = MIDI_COMMAND_INVALID;

			// Special handling for EOX command
			if (data == MIDI_COMMAND_SYSTEM_END_OF_EXCLUSIVE) {
				// Only return message if a SysEx command was in progress
				if (m->status == MIDI_COMMAND_SYSTEM_EXCLUSIVE) {
					msg->status = m->status;
					return true;
				}
			}
			break;
		case MIDI_STATUS_TYPE_SYSTEM_REAL_TIME:
			// System Real-time messages don't affect running status
			break;
		}

		int8_t data_bytes = midi_data_bytes(data);

		if (data_bytes < 0) {
			m->status = MIDI_COMMAND_INVALID;
			m->remaining_data_bytes = 0;
		} else {
			m->status = data;
			m->remaining_data_bytes = data_bytes;
			if (!data_bytes) {
				// Message has no data bytes, so we can just return it now
				msg->status = m->status;
				return true;
			}
		}
	} else {
		// Data byte

		// If we weren't expecting a data byte, check to see if running status
		// tells us to start a new message
		if (!m->remaining_data_bytes) {
			int8_t data_bytes = midi_data_bytes(m->running_status);
			if (data_bytes < 0) {
				m->status = MIDI_COMMAND_INVALID;
				m->remaining_data_bytes = 0;
			} else {
				m->status = m->running_status;
				m->remaining_data_bytes = data_bytes;
			}
		}

		// If we still don't expect a data byte, ignore it
		if (m->remaining_data_bytes) {
			const int8_t total_data_bytes = midi_data_bytes(m->status);
			// Status should already have been validated
			ASSERT(total_data_bytes > 0);

			msg->data[total_data_bytes - m->remaining_data_bytes] = data;
			--m->remaining_data_bytes;
			// We don't return from SysEx even when the buffer runs out
			if (!m->remaining_data_bytes
					&& m->status != MIDI_COMMAND_SYSTEM_EXCLUSIVE) {
				msg->status = m->status;
				return true;
			}
		}
	}

	return false;
}

uint8_t midi_msg_command(struct midi_msg* msg) {
	return msg->status & MIDI_STATUS_COMMAND_MASK;
}

uint8_t midi_msg_note(struct midi_msg* msg) {
	return msg->data[0];
}

uint8_t midi_msg_velocity(struct midi_msg* msg) {
	return msg->data[1];
}
