mod cpu;
use std::rc::Rc;

use cpu::*;
fn main() {
    let mut processor = Processor::default();

    processor.regx = 1;
    processor.load_program(Rc::new([(0x0200, 0x38), (0x0201, 0xEA)]));

    for _ in 0..20 {
        processor.tick();
    }

    dbg!(&processor);
}
