#import "fmt.odin";
#import "os.odin";

CPU :: struct {
	mem: [0x10000]byte,
	pc: u16,
	reg: [16]u8,
	sb: u16,
	sp: u16,
	hlt: bool,

	verbose: bool,
}

NOP   :: 0x00;
LDRC  :: 0x01;
LDRR  :: 0x02;
ADDRC :: 0x03;
ADDRR :: 0x04;
SUBRC :: 0x05;
SUBRR :: 0x06;
LDSPC :: 0x07;
LDSPR :: 0x08;
LDSBC :: 0x09;
LDSBR :: 0x0A;
HLT   :: 0x0B;
PUSHR :: 0x0C;
PUSHC :: 0x0D;
POPR  :: 0x0E;
POP   :: 0x0F;

/*

INCR  - INC rr

JMPRR - JMP rr:rc
JMPREL - JMP +-rr
JMPC - JMP c:d
CALLRR - CALL rr:rc
CALLC  - CALL c:d

*/

cpu_cycle :: proc(using cpu: ^CPU) {
	op := mem[pc];
	pc++;

	match op {
		case NOP: {
			// NOP
			fmt.println("NOP");
		}
		case LDRC: {
			r := mem[pc];
			pc++;
			c := mem[pc];
			pc++;

			reg[r] = c;
			if verbose {
				fmt.printf("LDRC - r%x = 0x%X\n", r, c);
			}
		}
		case LDRR: {
			r := mem[pc];
			pc++;
			c := mem[pc];
			pc++;

			reg[r] = reg[c];
			if verbose {
				fmt.printf("LDRR - r%x = r%x\n", r, c);
			}
		}
		case ADDRC: {
			r := mem[pc];
			pc++;
			c := mem[pc];
			pc++;

			reg[r] += c;
			if verbose {
				fmt.printf("ADDRC - r%x += %X\n", r, c);
			}
		}
		case ADDRR: {
			r := mem[pc];
			pc++;
			c := mem[pc];
			pc++;

			reg[r] += reg[c];
			if verbose {
				fmt.printf("ADDRR - r%x += r%x\n", r, c);
			}
		}
		case SUBRC: {
			r := mem[pc];
			pc++;
			c := mem[pc];
			pc++;

			reg[r] -= c;
			if verbose {
				fmt.printf("SUBRC - r%x -= %X\n", r, c);
			}
		}
		case SUBRR: {
			r := mem[pc];
			pc++;
			c := mem[pc];
			pc++;

			reg[r] -= reg[c];
			if verbose {
				fmt.printf("SUBRR - r%x -= r%x\n", r, c);
			}
		}
		case HLT: {
			hlt = true;
			if verbose {
				fmt.println("HLT");
			}
		}
		case PUSHR: {
			
		}
		case PUSHC: {
			
		}
		case POPR: {
			
		}
		case POP: {
			
		}
		
	}
}

cpu_dump :: proc(using cpu: ^CPU) {
	fmt.println("\n=======================================");

	fmt.printf("pc = 0x%X\n", pc);
	fmt.printf("sb = 0x%X\tsp = 0x%X\n", sb, sp);
	fmt.println("verbose =", verbose);
	fmt.println("hlt =", hlt);

	fmt.printf("\n");
	fmt.printf("r%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\n", 0, reg[0], 4, reg[4], 8, reg[8], 12, reg[12]);
	fmt.printf("r%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\n", 1, reg[1], 5, reg[5], 9, reg[9], 13, reg[13]);
	fmt.printf("r%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\n", 2, reg[2], 6, reg[6], 10, reg[10], 14, reg[14]);
	fmt.printf("r%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\tr%x = 0x%X\n", 3, reg[3], 7, reg[7], 11, reg[11], 15, reg[15]);
}

add_byte :: proc(using cpu: ^CPU, b: u8) {
	mem[pc] = b;
	pc++;
}

main :: proc() {
	cpu := new(CPU);
	cpu.verbose = true;

	add_byte(cpu, LDRC);
	add_byte(cpu, 0);
	add_byte(cpu, 127);
	add_byte(cpu, LDRR);
	add_byte(cpu, 1);
	add_byte(cpu, 0);

	add_byte(cpu, SUBRC);
	add_byte(cpu, 1);
	add_byte(cpu, 0xf);
	add_byte(cpu, SUBRR);
	add_byte(cpu, 0);
	add_byte(cpu, 1);

	add_byte(cpu, HLT);
	cpu.pc = 0;

	for {
		cpu_cycle(cpu);
		if cpu.hlt {
			break;
		}
	}

	cpu_dump(cpu);
}