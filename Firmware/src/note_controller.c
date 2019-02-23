#include <stdint.h>
#include "note_controller.h"

#define NOTE_CONTROLLER_DEFAULT_PERIOD 56818 // A4, 440.0014 Hz

#define NOTE_CONTROLLER_DEFAULT_ATTACK_AMPLITUDE 1000
#define NOTE_CONTROLLER_DEFAULT_SUSTAIN_AMPLITUDE 417
#define NOTE_CONTROLLER_DEFAULT_RELEASE_AMPLITUDE 1000

#define NOTE_CONTROLLER_DEFAULT_ATTACK_TIME 10000
#define NOTE_CONTROLLER_DEFAULT_RELEASE_TIME 3000

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
	switch(cont->state) {

	}
}
