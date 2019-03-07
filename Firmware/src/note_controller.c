#include <stdint.h>
#include <xtmrctr.h>
#include <stdio.h>
#include "note_controller.h"
#include "clock.h"

const struct note_controller_config NOTE_CONTROLLER_CONFIG_DEFAULT = {
		.period = 56818, // A4, 440.0014 Hz
		.attack_amplitude = 1000,
		.sustain_amplitude = 417,
		.release_amplitude = 1000,
		.attack_time = 30000, // us
		.release_time = 15000 // us
};

static void note_controller_update_period(struct note_controller *cont);

void note_controller_init(struct note_controller *cont,
		const struct string_driver* driver) {
	cont->driver = driver;
	cont->state = IDLE;
	cont->period_offset = 0;
	cont->state_start_time = 0;
	cont->attack_time = 0;
	note_controller_set_config(cont, &NOTE_CONTROLLER_CONFIG_DEFAULT);
}

void note_controller_update(struct note_controller *cont) {
	uint32_t state_time = clock_us() - cont->state_start_time;

	uint32_t amplitude = 0;
	bool inverted = false;

	switch (cont->state) {
	case IDLE:
		break;
	case ATTACK:
		amplitude = cont->config->attack_amplitude;
		if (state_time >= cont->attack_time) {
			cont->state = SUSTAIN;
		}
		break;
	case SUSTAIN:
		amplitude = cont->config->sustain_amplitude;
		break;
	case RELEASE:
		amplitude = cont->config->release_amplitude;
		inverted = true;
		if (state_time >= cont->config->release_time) {
			cont->state = IDLE;
		}
		break;
	}

	string_driver_set_amplitude(cont->driver, amplitude);
	string_driver_set_inverted(cont->driver, inverted);
}

void note_controller_start(struct note_controller *cont, uint8_t velocity) {
	cont->state_start_time = clock_us();
	cont->attack_time = (cont->config->attack_time * velocity) / 127;
	cont->state = ATTACK;
}

void note_controller_stop(struct note_controller *cont) {
	if (cont->state == IDLE)
		return;
	cont->state_start_time = clock_us();
	cont->state = RELEASE;
}

bool note_controller_is_started(const struct note_controller *cont) {
	return cont->state != IDLE;
}

void note_controller_set_config(struct note_controller *cont, const struct note_controller_config *config) {
	cont->config = config;
	note_controller_update_period(cont);
}

void note_controller_set_period_offset(struct note_controller *cont,
		int32_t period_offset) {
	cont->period_offset = period_offset;
	note_controller_update_period(cont);
}

void note_controller_pitch_bend(struct note_controller *cont,
		int16_t pitch_bend) {
	int32_t period_offset = pitch_bend / 2;
	note_controller_set_period_offset(cont, period_offset);
}

static void note_controller_update_period(struct note_controller *cont) {
	string_driver_set_period(cont->driver, cont->config->period + cont->period_offset);
}
