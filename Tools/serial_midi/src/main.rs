use std::ffi::CString;

use alsa::seq;
use clap;
use clap::Arg;
use clap::crate_authors;
use clap::crate_description;
use clap::crate_name;
use clap::crate_version;
use clap::value_t;
use failure::Error;

const BUFFER_SIZE: u32 = 512;

fn main() -> Result<(), Error> {
    let arg_matches = clap::App::new(crate_name!())
        .version(crate_version!())
        .author(crate_authors!())
        .about(crate_description!())
        .arg(Arg::with_name("baud")
            .short("b")
            .long("baud")
            .takes_value(true)
            .default_value("31250")
            .help("Serial port baud rate"))
        .arg(Arg::with_name("name")
            .short("n")
            .long("name")
            .takes_value(true)
            .default_value("serial_midi")
            .help("MIDI port name"))
        .arg(Arg::with_name("device")
            .required(true)
            .help("Serial port device"))
        .get_matches();

    let baud_rate = value_t!(arg_matches, "baud", u32).unwrap_or_else(|e| e.exit());
    let name = arg_matches.value_of("name").unwrap();
    let device = arg_matches.value_of("device").unwrap();

    let seq = seq::Seq::open(None, Some(alsa::Direction::Capture), false)?;
    seq.set_client_name(&CString::new("serial_midi")?)?;
    seq.create_simple_port(&CString::new(name)?,
                           seq::WRITE | seq::SUBS_WRITE,
                           seq::HARDWARE | seq::PORT)?;
    let mut seq_in = seq.input();

    let midi_event = seq::MidiEvent::new(BUFFER_SIZE)?;
    midi_event.enable_running_status(true);

    let mut num_subscribers = 0usize;

    let serial_settings = serialport::SerialPortSettings {
        baud_rate,
        ..serialport::SerialPortSettings::default()
    };

    let mut serial = None;

    loop {
        match seq_in.event_input_pending(true).and_then(|r| match r {
            0 => Ok(None),
            _ => seq_in.event_input().map(|ev| Some(ev)),
        }) {
            Err(e) => eprintln!("Warning: failed to get events: {}", e),
            Ok(Some(mut event)) => {
                let mut out_buf = [0u8; BUFFER_SIZE as usize];

                match event.get_type() {
                    seq::EventType::PortSubscribed => {
                        num_subscribers += 1;
                        if serial.is_none() {
                            match serialport::open_with_settings(device, &serial_settings) {
                                Ok(s) => serial = Some(s),
                                Err(e) => eprintln!("Error: Failed to open serial port: {}", e)
                            }
                        }
                    }
                    seq::EventType::PortUnsubscribed => {
                        if num_subscribers > 0 {
                            num_subscribers -= 1;
                        } else {
                            eprintln!("Warning: Client unsubscribed without subscribing")
                        }
                        if num_subscribers == 0 {
                            serial = None;
                        }
                    }
                    _ => if let Some(s) = &mut serial {
                        match midi_event.decode(&mut out_buf, &mut event) {
                            Ok(len) => {
                                if let Err(e) = s.write(&out_buf[0..len]) {
                                    eprintln!("Error: Failed to write to serial port: {}", e);
                                    serial = None;
                                }
                            }
                            Err(e) => {
                                eprintln!("Error: Failed to decode sequencer event: {:?}, {}", event, e);
                            }
                        }
                    }
                }
            }
            Ok(None) => () // No event
        }
    }
}

