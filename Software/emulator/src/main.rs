mod cpu;
use std::rc::Rc;

use cpu::*;
fn main() {
    let mut processor = Processor::default();

    processor.regx = 1;
    processor.load_program(Rc::new([(0x0001, 0xA5), (0x0200, 0xA5), (0x0201, 0x01)]));

    for _ in 0..10 {
        processor.tick();
    }

    dbg!(&processor);
}
