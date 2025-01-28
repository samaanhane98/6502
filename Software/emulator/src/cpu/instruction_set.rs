use std::ops::Shl;

use super::{compute_address, CpuState, Flags, Processor};

#[derive(Debug)]
pub enum AddressingMode {
    Implied,
    Immediate(u8),
    ZeroPage(u8),
    ZeroPageX(u8),
    ZeroPageY(u8), // Limited use
    Absolute(u16),
    AbsoluteX(u16),
    AbsoluteY(u16),
    IndexedIndirect(u8), // (Indirect, X)
    IndirectIndexed(u8), //(Indirect), Y
}

pub fn instruction_cycles(instruction: u8) -> u8 {
    match instruction {
        0x0 => 0,
        0x18 | 0x38 | 0xB8 | 0xEA => 2,
        0x69 | 0x29 | 0x0A | 0x90 | 0xA9 | 0xA2 | 0xA0 => 4,
        0x65 | 0x25 | 0xA5 | 0xA6 | 0xA4 => 5,
        0x75 | 0x6D | 0x7D | 0x79 | 0x35 | 0x2D | 0x3D | 0x39 | 0xB5 | 0xAD | 0xB6 | 0xAE
        | 0xB4 | 0xAC => 6,
        0x71 | 0x31 | 0x06 | 0xBD | 0xB9 | 0xBE | 0xBC => 7,
        0x61 | 0x21 | 0x16 | 0x0E | 0xA1 | 0xB1 => 8,
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

    // ? lda
    match pc_data[0] {
        0xA9 => lda(cpu, AddressingMode::Immediate(pc_data[1])),
        0xA5 => lda(cpu, AddressingMode::ZeroPage(pc_data[1])),
        0xB5 => lda(cpu, AddressingMode::ZeroPageX(pc_data[1])),
        0xAD => {
            lda(
                cpu,
                AddressingMode::Absolute(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        0xBD => {
            lda(
                cpu,
                AddressingMode::AbsoluteX(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        0xB9 => {
            lda(
                cpu,
                AddressingMode::AbsoluteY(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        0xA1 => lda(cpu, AddressingMode::IndexedIndirect(pc_data[1])),
        0xB1 => lda(cpu, AddressingMode::IndirectIndexed(pc_data[1])),
        _ => {}
    }

    // ? ldx
    match pc_data[0] {
        0xA2 => ldx(cpu, AddressingMode::Immediate(pc_data[1])),
        0xA6 => ldx(cpu, AddressingMode::ZeroPage(pc_data[1])),
        0xB6 => ldx(cpu, AddressingMode::ZeroPageY(pc_data[1])),
        0xAE => {
            ldx(
                cpu,
                AddressingMode::Absolute(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        0xBE => {
            ldx(
                cpu,
                AddressingMode::AbsoluteY(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        _ => {}
    }

    // ? ldy
    match pc_data[0] {
        0xA0 => ldy(cpu, AddressingMode::Immediate(pc_data[1])),
        0xA4 => ldy(cpu, AddressingMode::ZeroPage(pc_data[1])),
        0xB4 => ldy(cpu, AddressingMode::ZeroPageX(pc_data[1])),
        0xAC => {
            ldy(
                cpu,
                AddressingMode::Absolute(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        0xBC => {
            ldy(
                cpu,
                AddressingMode::AbsoluteX(u16::from_le_bytes([pc_data[1], pc_data[2]])),
            );
        }
        _ => {}
    }

    // ? status instructions
    match pc_data[0] {
        0x18 | 0x38 | 0xB8 => {
            status(cpu, pc_data[0]);
            cpu.pc -= 1;
        }
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
        _ => {
            let carry = match cpu.status.contains(Flags::CARRY) {
                true => 1,
                false => 0,
            };
            let mem_address = compute_address(*cpu, mode);
            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u16 = cpu.acc as u16 + mem_val as u16 + carry as u16;

            cpu.status.set(Flags::CARRY, new_acc > 0xFF);
            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc as u8;
        }
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
        _ => {
            let mem_address = compute_address(*cpu, mode);
            let mem_val = cpu.memory[mem_address as usize];

            let new_acc: u8 = cpu.acc & mem_val;

            cpu.status.set(Flags::ZERO, new_acc == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, new_acc & 0b1000_0000 == 0b1000_0000);

            cpu.acc = new_acc;
        }
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
        _ => {
            let mem_address = compute_address(*cpu, mode);
            let mut mem_val = cpu.memory[mem_address as usize];
            cpu.status
                .set(Flags::CARRY, mem_val & 0b1000_0000 == 0b1000_0000);

            mem_val = mem_val.shl(1);

            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);

            cpu.memory[mem_address as usize] = mem_val;
        }
    }
}

pub fn lda(cpu: &mut Processor, mode: AddressingMode) {
    match mode {
        AddressingMode::Immediate(data) => {
            cpu.status.set(Flags::ZERO, data == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, data & 0b1000_0000 == 0b1000_0000);
            cpu.acc = data;
        }
        _ => {
            let mem_address = compute_address(*cpu, mode);
            let mem_val = cpu.memory[mem_address as usize];
            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);
            cpu.acc = mem_val;
        }
    }
}

pub fn ldx(cpu: &mut Processor, mode: AddressingMode) {
    match mode {
        AddressingMode::Immediate(data) => {
            cpu.status.set(Flags::ZERO, data == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, data & 0b1000_0000 == 0b1000_0000);
            cpu.regx = data;
        }
        _ => {
            let mem_address = compute_address(*cpu, mode);
            let mem_val = cpu.memory[mem_address as usize];
            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);
            cpu.regx = mem_val;
        }
    }
}

pub fn ldy(cpu: &mut Processor, mode: AddressingMode) {
    match mode {
        AddressingMode::Immediate(data) => {
            cpu.status.set(Flags::ZERO, data == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, data & 0b1000_0000 == 0b1000_0000);
            cpu.regy = data;
        }
        _ => {
            let mem_address = compute_address(*cpu, mode);
            let mem_val = cpu.memory[mem_address as usize];
            cpu.status.set(Flags::ZERO, mem_val == 0x00);
            cpu.status
                .set(Flags::NEGATIVE, mem_val & 0b1000_0000 == 0b1000_0000);
            cpu.regy = mem_val;
        }
    }
}

pub fn status(cpu: &mut Processor, instr: u8) {
    match instr {
        0x18 => cpu.status.set(Flags::CARRY, false),
        0x38 => cpu.status.set(Flags::CARRY, true),
        0xB8 => cpu.status.set(Flags::OVERFLOW, false),
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
