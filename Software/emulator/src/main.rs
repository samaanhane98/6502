mod cpu;
use std::rc::Rc;

use cpu::*;
fn main() {
    let mut processor = Processor::default();

    processor.regx = 1;
    processor.load_program(Rc::new([
        (0x0100, 0x01),
        (0x0200, 0x69),
        (0x0201, 0x01),
        (0x0202, 0x1E),
        (0x0203, 0xFF),
        (0x0204, 0x00),
    ]));

    for _ in 0..20 {
        processor.tick();
    }

    dbg!(&processor.memory[0x100]);
}
