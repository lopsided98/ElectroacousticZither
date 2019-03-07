#!/usr/bin/env python3
import argparse
import math
from enum import IntEnum, unique
from typing import Optional

import aubio
import numpy as np
import pyaudio
import serial

SAMPLE_RATE = 44100
HOP_SIZE = 4096


@unique
class MIDICommand(IntEnum):
    INVALID = 0x00,
    NOTE_OFF = 0x80,
    NOTE_ON = 0x90,
    POLYPHONIC_PRESSURE = 0xA0,
    CONTROL_CHANGE = 0xB0,
    PROGRAM_CHANGE = 0xC0,
    CHANNEL_PRESSURE = 0xD0,
    PITCH_BEND = 0xE0,
    SYSTEM = 0xF0


@unique
class MIDICommandSystem(IntEnum):
    EXCLUSIVE = 0xF0,
    TIME_CODE_QUARTER_FRAME = 0xF1,
    SONG_POSITON = 0xF2,
    SONG_SELECT = 0xF3,
    TUNE_REQUEST = 0xF6,
    END_OF_EXCLUSIVE = 0xF7,
    TIMING_CLOCK = 0xF8,
    START = 0xFA,
    CONTINUE = 0xFB,
    STOP = 0xFC,
    ACTIVE_SENSE = 0xFE,
    RESET = 0xFF


class MIDICommandSysEx(IntEnum):
    FREQUENCY = 0x42


class MIDINote(IntEnum):
    C2 = 36,
    D2 = 38,
    E2 = 40,
    F2 = 41,
    G2 = 43,
    A2 = 45,
    B2 = 47,
    C3 = 48,
    D3 = 50,
    E3 = 52,
    F3 = 53,
    G3 = 55,
    A3 = 57,
    A_SHARP3 = 58,
    B_FLAT3 = 58,
    B3 = 59,
    C4 = 60,
    D4 = 62,
    E4 = 64,
    F4 = 65,
    G4 = 67,
    A4 = 69,
    A_SHARP4 = 70,
    B_FLAT4 = 70,
    B4 = 71,
    C5 = 72,
    D5 = 74,
    E5 = 76,
    F5 = 77,
    G5 = 79,
    A5 = 81,
    B5 = 83


class MIDI:
    def __init__(self, device_name: str = '/dev/ttyUSB0', baud: int = 115200):
        self._serial = serial.Serial(device_name, baud)

    def send_note_on(self, note: MIDINote, velocity: int = 64):
        self._serial.write(bytes((MIDICommand.NOTE_ON, note, velocity)))

    def send_note_off(self, note: MIDINote, velocity: int = 64):
        self._serial.write(bytes((MIDICommand.NOTE_OFF, note, velocity)))

    def send_frequency(self, note: MIDINote, frequency: float):
        frequency = round(frequency * 100)

        self._serial.write(bytes((
            MIDICommand.SYSTEM | MIDICommandSystem.EXCLUSIVE,
            note,
            MIDICommandSysEx.FREQUENCY,
            frequency & 0x7F,
            (frequency >> 7) & 0x7F,
            (frequency >> 14) & 0x7F,
            (frequency >> 21) & 0x7F,
            (frequency >> 28) & 0xF,
            MIDICommand.SYSTEM | MIDICommandSystem.END_OF_EXCLUSIVE
        )))


A4 = 440
C0 = A4 * pow(2, -4.75)

NOTE_NAMES = ('C', 'C_SHARP', 'D', 'D_SHARP', 'E', 'F', 'F_SHARP', 'G', 'G_SHARP', 'A', 'B_FLAT', "B")


def find_closest_note(freq: float) -> (str, Optional[MIDINote], float):
    h = round(12 * math.log2(freq / C0))
    octave = h // 12
    n = h % 12

    nominal_freq = C0 * (2 ** (h / 12))

    note_name = NOTE_NAMES[n] + str(octave)
    try:
        midi_note = MIDINote[note_name]
    except KeyError:
        midi_note = None

    return note_name, midi_note, nominal_freq


SCALE = {MIDINote.F3, MIDINote.G3, MIDINote.A3, MIDINote.B_FLAT3, MIDINote.C4, MIDINote.D4, MIDINote.E4, MIDINote.F4}


def main():
    parser = argparse.ArgumentParser(description="Electroacoustic zither tuner")
    parser.add_argument('device', default='/dev/ttyUSB0', nargs='?', help="serial port device")
    parser.add_argument('-b', '--baud', type=int, default=115200, help="serial port baud rate")
    args = parser.parse_args()

    p = pyaudio.PyAudio()

    stream = p.open(format=pyaudio.paFloat32,
                    channels=1,
                    rate=SAMPLE_RATE,
                    frames_per_buffer=HOP_SIZE,
                    input=True)

    pitch_detect = aubio.pitch("mcomb", HOP_SIZE * 8, HOP_SIZE, SAMPLE_RATE)
    pitch_detect.set_unit("Hz")
    pitch_detect.set_silence(-40)

    midi = MIDI(device_name=args.device, baud=args.baud)

    prev_note = None

    avg_freq = 0

    while True:
        data = stream.read(HOP_SIZE)
        samples = np.fromstring(data, dtype=aubio.float_type)

        freq = float(pitch_detect(samples)[0])

        if freq == 0:
            continue
        note_name, midi_note, nominal_freq = find_closest_note(freq)

        if midi_note not in SCALE:
            continue

        if midi_note != prev_note:
            if prev_note is not None:
                midi.send_note_off(prev_note)
            midi.send_note_on(midi_note)
            prev_note = midi_note
            avg_freq = freq

        # Rolling average
        avg_freq = avg_freq * 0.9 + freq * 0.1

        print("{:<9} {:>7.2f} Hz, avg: {:>7.2f} Hz, delta: {:>6.2f}"
              .format(note_name, freq, avg_freq, avg_freq - nominal_freq))

        midi.send_frequency(midi_note, avg_freq)


if __name__ == "__main__":
    main()
