#!/usr/bin/env python3
from enum import IntEnum

import aubio
import numpy as np
import pyaudio
import serial

SAMPLE_RATE = 44100
HOP_SIZE = 4096


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
    A3_SHARP = 58,
    B3_FLAT = 58,
    B3 = 59,
    C4 = 60,
    D4 = 62,
    E4 = 64,
    F4 = 65,
    G4 = 67,
    A4 = 69,
    A4_SHARP = 70,
    B4_FLAT = 70,
    B4 = 71,
    C5 = 72,
    D5 = 74,
    E5 = 76,
    F5 = 77,
    G5 = 79,
    A5 = 81,
    B5 = 83


class MIDI:
    def __init__(self, device_name: str = '/dev/ttyUSB3', baud: int = 115200):
        self._serial = serial.Serial(device_name, baud)

    def send_note_on(self, note: MIDINote):
        self._serial.write(bytes((MIDICommand.NOTE_ON, note, 64)))

    def send_frequency(self, note: MIDINote, frequency: int):
        self._serial.write(bytes((
            MIDICommand.SYSTEM | MIDICommandSystem.EXCLUSIVE,
            note,
            MIDICommandSysEx.FREQUENCY,
            frequency & 0x7F,
            (frequency >> 7) & 0x7F,
            (frequency >> 14) & 0x7F,
            (frequency >> 28) & 0xF,
            MIDICommand.SYSTEM | MIDICommandSystem.END_OF_EXCLUSIVE
        )))


def main():
    p = pyaudio.PyAudio()

    stream = p.open(format=pyaudio.paFloat32,
                    channels=1,
                    rate=SAMPLE_RATE,
                    frames_per_buffer=HOP_SIZE,
                    input=True)

    pitch_detect = aubio.pitch("fcomb", HOP_SIZE * 8, HOP_SIZE, SAMPLE_RATE)
    pitch_detect.set_unit("Hz")
    pitch_detect.set_silence(-32)

    midi = MIDI()

    while True:
        data = stream.read(HOP_SIZE)
        samples = np.fromstring(data, dtype=aubio.float_type)

        freq = float(pitch_detect(samples)[0])

        if freq != 0:
            midi.send_frequency(MIDINote.F3, round(freq * 100))

        print("{} Hz".format(freq))


if __name__ == "__main__":
    main()
