#pragma once
#include "string_driver.h"

const struct note_controller_config NOTE_CONTROLLER_CONFIG_DEFAULT;

enum note_controller_state {
	IDLE,
	ATTACK,
	SUSTAIN,
	RELEASE
};

struct note_controller_config {
	/**
	 * Period for this configuration (in cycles)
	 */
	uint32_t period;
	uint32_t attack_amplitude;
	uint32_t sustain_amplitude;
	uint32_t release_amplitude;
	uint32_t attack_time;
	uint32_t release_time;
};

struct note_controller {
	const struct string_driver *driver;
	enum note_controller_state state;

	uint32_t state_start_time;
	int32_t period_offset;
	// Attack time is modulated by velocity
	uint32_t attack_time;

	const struct note_controller_config *config;
};

void note_controller_init(struct note_controller *cont,
		const struct string_driver* driver);

void note_controller_update(struct note_controller *cont);

void note_controller_start(struct note_controller *cont, uint8_t velocity);

void note_controller_stop(struct note_controller *cont);

bool note_controller_is_started(const struct note_controller *cont);

void note_controller_set_config(struct note_controller *cont,
		const struct note_controller_config *config);

void note_controller_set_period_offset(struct note_controller *cont,
		int32_t period_offset);

void note_controller_pitch_bend(struct note_controller *cont,
		int16_t pitch_bend);
