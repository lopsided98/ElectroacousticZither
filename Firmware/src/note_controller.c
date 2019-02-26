#include <stdint.h>
#include <xtmrctr.h>
#include "note_controller.h"
#include "clock.h"

#define NOTE_CONTROLLER_DEFAULT_PERIOD 56818 // A4, 440.0014 Hz

#define NOTE_CONTROLLER_DEFAULT_ATTACK_AMPLITUDE 1000
#define NOTE_CONTROLLER_DEFAULT_SUSTAIN_AMPLITUDE 417
#define NOTE_CONTROLLER_DEFAULT_RELEASE_AMPLITUDE 1000

#define NOTE_CONTROLLER_DEFAULT_ATTACK_TIME 30000 // us
#define NOTE_CONTROLLER_DEFAULT_RELEASE_TIME 15000 // us

void note_controller_init(struct note_controller *cont, const struct string_driver* driver) {
	cont->driver = driver;
	cont->state = IDLE;
	cont->period = NOTE_CONTROLLER_DEFAULT_PERIOD;
	cont->attack_amplitude = NOTE_CONTROLLER_DEFAULT_ATTACK_AMPLITUDE;
	cont->sustain_amplitude = NOTE_CONTROLLER_DEFAULT_SUSTAIN_AMPLITUDE;
	cont->release_amplitude = NOTE_CONTROLLER_DEFAULT_RELEASE_AMPLITUDE;

	cont->attack_time = NOTE_CONTROLLER_DEFAULT_ATTACK_TIME;
	cont->release_time = NOTE_CONTROLLER_DEFAULT_RELEASE_TIME;

	string_driver_set_period(driver, cont->period);
}

void note_controller_update(struct note_controller *cont) {
	uint32_t state_time = clock_us() - cont->state_start_time;

	uint32_t amplitude = 0;
	bool inverted = false;

	switch(cont->state) {
		case IDLE:
			break;
		case ATTACK:
			amplitude = cont->attack_amplitude;
			if (state_time >= cont->attack_time) {
				cont->state = SUSTAIN;
			}
			break;
		case SUSTAIN:
			amplitude = cont->sustain_amplitude;
			break;
		case RELEASE:
			amplitude = cont->release_amplitude;
			inverted = true;
			if (state_time >= cont->release_time) {
				cont->state = IDLE;
			}
			break;
	}

	string_driver_set_amplitude(cont->driver, amplitude);
	string_driver_set_inverted(cont->driver, inverted);
}

void note_controller_start(struct note_controller *cont) {
	cont->state_start_time = clock_us();
	cont->state = ATTACK;
}

void note_controller_stop(struct note_controller *cont) {
	cont->state_start_time = clock_us();
	cont->state = RELEASE;
}

void note_controller_set_period(struct note_controller *cont, uint32_t period) {
	cont->period = period;
	string_driver_set_period(cont->driver, period);
}
