mod cpu;
use std::rc::Rc;

use cpu::*;
fn main() {
    let mut processor = Processor::default();

    processor.regx = 1;
    processor.load_program(Rc::new([
        (0x0200, 0xA9),
        (0x0201, 0x01),
        (0x0202, 0xA2),
        (0x0203, 0x01),
        (0x0204, 0xA0),
        (0x0205, 0x00),
    ]));

    for _ in 0..20 {
        processor.tick();
    }

    dbg!(&processor);
}
