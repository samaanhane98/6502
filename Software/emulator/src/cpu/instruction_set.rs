use std::ops::Shl;

use super::{CpuState, Flags, Processor};

#[derive(Debug)]
pub enum AddressingMode {
    Implied,
    Immediate(u8),
    ZeroPage(u8),
    ZeroPageX(u8),
    Absolute(u16),
    AbsoluteX(u16),
    AbsoluteY(u16),
    IndexedIndirect(u8), // (Indirect, X)
    IndirectIndexed(u8), //(Indirect), Y
}

pub fn instruction_cycles(instruction: u8) -> u8 {
    match instruction {
        0x0 => 0,
        0x69 | 0x29 | 0x0A | 0x90 => 4,
        0x65 | 0x25 => 5,
        0x75 | 0x6D | 0x7D | 0x79 | 0x35 | 0x2D | 0x3D | 0x39 => 6,
        0x71 | 0x31 | 0x06 => 7,
        0x61 | 0x21 | 0x16 | 0x0E => 8,
        0x1E => 9,
        _ => unimplemented!(),
    }
}

pub fn execute(cpu: &mut Processor) {
    let pc_data: [u8; 3] = [
        cpu.memory[cpu.pc as usize],
        cpu.memory[(cpu.pc + 1) as usize],
        cpu.memory[(cpu.pc + 2) as usize],
    ];

    // ? adc
    match pc_data[0] {
        0x69 => adc(cpu, AddressingMode::Immediate(pc_data[1])),
        0x65 => adc(cpu, AddressingMode::ZeroPage(pc_data[1])),
        0x75 => adc(cpu, AddressingMode::ZeroPageX(pc_data[1])),
        0x6D => {
            adc(
                cpu,
                AddressingMode::Absolute(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }
        0x7D => {
            adc(
                cpu,
                AddressingMode::AbsoluteX(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }
        0x79 => {
            adc(
                cpu,
                AddressingMode::AbsoluteY(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }
        0x61 => adc(cpu, AddressingMode::IndexedIndirect(pc_data[1])),
        0x71 => adc(cpu, AddressingMode::IndirectIndexed(pc_data[1])),
        _ => {}
    }

    // ? and
    match pc_data[0] {
        0x29 => and(cpu, AddressingMode::Immediate(pc_data[1])),
        0x25 => and(cpu, AddressingMode::ZeroPage(pc_data[1])),
        0x35 => and(cpu, AddressingMode::ZeroPageX(pc_data[1])),
        0x2D => {
            and(
                cpu,
                AddressingMode::Absolute(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }
        0x3D => {
            and(
                cpu,
                AddressingMode::AbsoluteX(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }
        0x39 => {
            and(
                cpu,
                AddressingMode::AbsoluteY(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }

        0x21 => and(cpu, AddressingMode::IndexedIndirect(pc_data[1])),
        0x31 => and(cpu, AddressingMode::IndirectIndexed(pc_data[1])),
        _ => {}
    }

    // ? asl
    match pc_data[0] {
        0x0A => {
            asl(cpu, AddressingMode::Implied);
            cpu.pc -= 1;
        }
        0x06 => asl(cpu, AddressingMode::ZeroPage(pc_data[1])),
        0x16 => asl(cpu, AddressingMode::ZeroPageX(pc_data[1])),
        0x0E => {
            asl(
                cpu,
                AddressingMode::Absolute(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }
        0x1E => {
            asl(
                cpu,
                AddressingMode::AbsoluteX(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
            cpu.pc += 1;
        }

        _ => {}
    }

    // ? bcc
    match pc_data[0] {
        0x90 => bcc(cpu, pc_data[1]),
        _ => {}
    }
}

pub fn adc(cpu: &mut Processor, mode: AddressingMode) {
    match mode {
        AddressingMode::Immediate(data) => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };

            let new_acc: u16 = cpu.acc as u16 + data as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        AddressingMode::ZeroPage(address) => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };

            let mem_val = cpu.memory[address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        AddressingMode::ZeroPageX(address) => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };
            let mem_address = address.wrapping_add(cpu.regx);
            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        AddressingMode::Absolute(address) => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };
            let mem_val = cpu.memory[address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        AddressingMode::AbsoluteX(address) => {
            let mem_address = address + cpu.regx as u16;

            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };
            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }

        AddressingMode::AbsoluteY(address) => {
            let mem_address = address + cpu.regy as u16;

            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };
            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        AddressingMode::IndexedIndirect(pointer) => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };

            let zero_page_address = cpu.memory[pointer as usize];
            let mem_address = u16::from_le_bytes([
                cpu.memory[zero_page_address.wrapping_add(cpu.regx) as usize],
                cpu.memory[zero_page_address.wrapping_add(cpu.regx).wrapping_add(1) as usize],
            ]);

            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        AddressingMode::IndirectIndexed(pointer) => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };

            let zero_page_address = u16::from_le_bytes([
                cpu.memory[pointer as usize],
                cpu.memory[pointer as usize + 1],
            ]);

            let mem_address: u16 = zero_page_address + cpu.regy as u16;

            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
        _ => unreachable!(),
    }
}

pub fn and(cpu: &mut Processor, mode: AddressingMode) {
    match mode {
        AddressingMode::Immediate(data) => {
            let new_acc: u8 = cpu.acc & data;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::ZeroPage(address) => {
            let mem_val = cpu.memory[address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::ZeroPageX(address) => {
            let mem_address = address.wrapping_add(cpu.regx);
            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::Absolute(address) => {
            let mem_val = cpu.memory[address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::AbsoluteX(address) => {
            let mem_address = address + cpu.regx as u16;

            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::AbsoluteY(address) => {
            // Page cross condition
            let mem_address = address + cpu.regy as u16;

            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::IndexedIndirect(pointer) => {
            let zero_page_address = cpu.memory[pointer as usize];

            let mem_address = u16::from_le_bytes([
                cpu.memory[zero_page_address.wrapping_add(cpu.regx) as usize],
                cpu.memory[zero_page_address.wrapping_add(cpu.regx).wrapping_add(1) as usize],
            ]);

            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::IndirectIndexed(pointer) => {
            let zero_page_address = u16::from_le_bytes([
                cpu.memory[pointer as usize],
                cpu.memory[pointer as usize + 1],
            ]);

            let mem_address: u16 = zero_page_address + cpu.regy as u16;

            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        _ => unreachable!(),
    }
}

pub fn asl(cpu: &mut Processor, mode: AddressingMode) {
    match mode {
        AddressingMode::Implied => {
            cpu.status
                .set(Flags::CARRY, cpu.acc & 0b1000_0000 == 0b1000_0000);

            let new_acc = cpu.acc.shl(1);

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
        AddressingMode::ZeroPage(address) => {
            let mut mem_val = cpu.memory[address as usize];
            cpu.status
                .set(Flags::CARRY, mem_val & 0b1000_0000 == 0b1000_0000);

            mem_val = mem_val.shl(1);

            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);

            cpu.memory[address as usize] = mem_val;
        }
        AddressingMode::ZeroPageX(address) => {
            let mem_address = address.wrapping_add(cpu.regx);

            let mut mem_val = cpu.memory[mem_address as usize];

            cpu.status
                .set(Flags::CARRY, mem_val & 0b1000_0000 == 0b1000_0000);

            mem_val = mem_val.shl(1);

            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);

            cpu.memory[mem_address as usize] = mem_val;
        }
        AddressingMode::Absolute(address) => {
            let mut mem_val = cpu.memory[address as usize];
            cpu.status
                .set(Flags::CARRY, mem_val & 0b1000_0000 == 0b1000_0000);

            mem_val = mem_val.shl(1);

            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);

            cpu.memory[address as usize] = mem_val;
        }
        AddressingMode::AbsoluteX(address) => {
            let mem_address = address + cpu.regx as u16;

            let mut mem_val = cpu.memory[mem_address as usize];

            cpu.status
                .set(Flags::CARRY, mem_val & 0b1000_0000 == 0b1000_0000);

            mem_val = mem_val.shl(1);

            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);

            cpu.memory[mem_address as usize] = mem_val;
        }
        _ => unreachable!(),
    }
}

// ! Check page cross here
pub fn bcc(cpu: &mut Processor, offset: u8) {
    match cpu.status.contains(Flags::CARRY) {
        true => {
            let jump_address: u16 = cpu.pc + offset as u16;
            if (jump_address & 0xFF00) != (cpu.pc & 0xFF00) {
                cpu.state = CpuState::PageCross(2);
            } else {
                cpu.state = CpuState::PageCross(1);
            }

            cpu.pc = jump_address;
        }
        false => (),
    };
}
