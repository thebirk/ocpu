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

cpu_new :: proc() -> ^CPU {
	cpu := new(CPU);
	
	return cpu;
}

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
			
		}
		case SUBRR: {
			
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

main :: proc() {
	cpu := cpu_new();
	cpu.verbose = true;

	cpu.mem[0] = LDRC;
	cpu.mem[1] = 0;
	cpu.mem[2] = 127;
	cpu.mem[3] = LDRR;
	cpu.mem[4] = 1;
	cpu.mem[5] = 0;
	cpu.mem[6] = HLT;

	for {
		cpu_cycle(cpu);
		if cpu.hlt {
			break;
		}
	}

	cpu_dump(cpu);
}