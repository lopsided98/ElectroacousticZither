#pragma once
#include "string_driver.h"

enum note_controller_state {
	IDLE,
	ATTACK,
	SUSTAIN,
	RELEASE
};

struct note_controller {
	const struct string_driver *driver;
	enum note_controller_state state;
	uint32_t period;

	uint32_t attack_amplitude;
	uint32_t sustain_amplitude;
	uint32_t release_amplitude;

	uint16_t attack_time;
	uint16_t release_time;

	uint32_t state_start_time;
};

void note_controller_init(struct note_controller *cont, const struct string_driver* driver);

void note_controller_update(struct note_controller *cont);

void note_controller_start(struct note_controller *cont);

void note_controller_stop(struct note_controller *cont);

void note_controller_set_period(struct note_controller *cont, uint32_t period);
