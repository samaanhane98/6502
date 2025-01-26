use bitflags::bitflags;
use std::{fmt::Debug, rc::Rc};

mod instruction_set;
use instruction_set::*;

#[cfg(test)]
mod test;

bitflags! {
    #[derive(Debug, Clone, Copy)]
    pub struct Flags: u8 {
        const CARRY = 0b0000_0001;
        const ZERO = 0b0000_0010;
        const INTERRUPT_DISABLE = 0b0000_0100;
        const DECIMAL_MODE = 0b0000_1000;
        const BREAK = 0b0001_0000;
        const OVERFLOW = 0b0010_0000;
        const NEGATIVE = 0b0100_0000;
    }
}

#[derive(Debug, Clone, Copy)]
pub enum CpuState {
    Busy(u8),
    Idle,
    PageCross(u8),
}

// $0000-$00FF: Zero Page
// $0100-$01FF: System stack
// $FFFA-$FFFF: reserved
#[derive(Clone, Copy)]
pub struct Processor {
    pub memory: [u8; 0xFFFF],
    pub pc: u16,
    pub sp: u8,
    pub acc: u8,
    pub regx: u8,
    pub regy: u8,
    pub status: Flags,

    state: CpuState,
}

impl Default for Processor {
    fn default() -> Self {
        Self {
            memory: [0; 0xFFFF],
            pc: 0x0200,
            sp: 0x00,
            acc: 0x00,
            regx: 0x00,
            regy: 0x00,
            status: Flags::empty(),
            state: CpuState::Idle,
        }
    }
}

impl Debug for Processor {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Processor")
            .field("state", &self.state)
            .field("pc", &format!("{:04x}", &self.pc))
            .field("sp", &format!("{:02x}", &self.sp))
            .field("acc", &self.acc)
            .field("regx", &self.regx)
            .field("regy", &self.regy)
            .field("status", &format!("{:08b}", self.status.bits()))
            .finish()
    }
}

impl Processor {
    pub fn load_program(&mut self, program: Rc<[(u16, u8)]>) {
        for (address, byte) in program.iter() {
            self.memory[*address as usize] = *byte;
        }
    }

    pub fn tick(&mut self) {
        // Little Endian -> Big Endian
        let opcode: u8 = self.memory[self.pc as usize];

        match self.state {
            CpuState::Idle => {
                // ? Fetch
                match instruction_cycles(opcode) {
                    0 => self.state = CpuState::Idle,
                    new_pc => self.state = CpuState::Busy(new_pc - 1),
                }
            }
            CpuState::Busy(cycles_left) => {
                // ? In the final cycle, we execute
                match cycles_left {
                    0 => unreachable!(),
                    1 => {
                        // Update state first because execute might overwrite it due to page cross
                        self.state = CpuState::Idle;

                        // Execute
                        execute(self);
                        self.pc += 0x2;
                    }
                    _ => {
                        self.state = CpuState::Busy(cycles_left - 1);
                    }
                }
            }
            CpuState::PageCross(cycles_left) => match cycles_left {
                0 => unreachable!(),
                1 => {
                    self.state = CpuState::Idle;
                }
                _ => {
                    self.state = CpuState::PageCross(cycles_left - 1);
                }
            },
        }
    }
}

pub fn compute_address(cpu: Processor, mode: AddressingMode) -> usize {
    match mode {
        AddressingMode::Immediate(address) => address as usize,
        AddressingMode::ZeroPage(address) => address as usize,
        AddressingMode::ZeroPageX(address) => address.wrapping_add(cpu.regx) as usize,
        AddressingMode::Absolute(address) => address as usize,
        AddressingMode::AbsoluteX(address) => (address + cpu.regx as u16) as usize,
        AddressingMode::AbsoluteY(address) => (address + cpu.regy as u16) as usize,
        AddressingMode::IndexedIndirect(pointer) => {
            let zero_page_address = cpu.memory[pointer as usize];
            let mem_address = u16::from_le_bytes([
                cpu.memory[zero_page_address.wrapping_add(cpu.regx) as usize],
                cpu.memory[zero_page_address.wrapping_add(cpu.regx).wrapping_add(1) as usize],
            ]);

            mem_address as usize
        }
        AddressingMode::IndirectIndexed(pointer) => {
            let zero_page_address = u16::from_le_bytes([
                cpu.memory[pointer as usize],
                cpu.memory[pointer as usize + 1],
            ]);

            (zero_page_address + cpu.regy as u16) as usize
        }
        _ => unimplemented!(),
    }
}
