# CPU Project

This projects is an attempt at a CPU build for the Pynq Z2 board. The inspiration for the CPU is the 6502 processor. Much of the VHDL is based on the following repo: https://github.com/bernardo-andreeti/6502.

# ISA

Eventually, all 6502 legal instructions will be supported. Currently, the following instructions have been considered:

- [x] ADC
- - [x] IMM
- - [x] ZERO PAGE
- - [x] ZERO PAGE X
- - [x] ABS
- - [x] ABS,X
- - [x] ABS,Y
- - [x] Indirect Indexed
- - [x] Indexed Indirect

- [x] LDA
- - [x] IMM
- - [x] ZERO PAGE
- - [x] ZERO PAGE X
- - [x] ABS
- - [x] ABS,X
- - [x] ABS,Y
- - [x] Indexed Indirect
- - [x] Indirect Indexed

- [x] LDX
- - [x] IMM
- - [x] ZERO PAGE
- - [x] ABS
- - [x] ABS,Y

- [x] LDY
- - [x] IMM
- - [x] ZERO PAGE
- - [x] ZERO PAGE X
- - [x] ABS
- - [x] ABS,X

- [ ] JMP
- - [x] ABS
- - [ ] INDIRECT

- [x] NOP
- [ ] BCC
- [ ] BCS
- [ ] BEQ
- [ ] BMI
- [ ] BNE
- [ ] BPL
- [ ] BVC
- [ ] BVS
- [x] CLC
- [x] SEC
- [x] CLV
- [ ] DEX
- [ ] DEY
- [ ] INX
- [ ] INY

# Links

1. http://www.visual6502.org/JSSim/expert.html?a=0&d=a900a8187170c8c00ad0f860
2. https://www.scribd.com/document/550073922/10-1-1-725-1843
