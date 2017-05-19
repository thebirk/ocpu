#import "fmt.odin";
#import "os.odin";
#import "utf8.odin";
#load "opcodes.odin";

Lexer :: struct {
	file: []byte,
	offset: int,

	last_rune_size: int,
}

Parser :: struct {
	using lexer: Lexer,
}

init_lexer :: proc(using lexer: ^Lexer, path: string) {
	offset = 0;

	ok: bool;
	file, ok = os.read_entire_file(path);
	if !ok {
		fmt.printf("Failed to open file '%s'\n", path);
		os.exit(1);
	}
}

TokenType :: enum {
	Comma,
	Colon,
	Dot,
	Ident,
	Number,
	String,
	Newline,
	Register,
	EOF,
	Unknown,
}

Token :: struct {
	type: TokenType,
	lexeme: string,
}

is_whitespace :: proc(r: rune) -> bool {
	return (r == ' ') || (r == '\t') || (r == '\r');
}

eat_whitespace :: proc(using lexer: ^Lexer) {
	r := get_rune(lexer);
	for r != utf8.RUNE_ERROR && is_whitespace(r) {
		r = get_rune(lexer);
	}
	if r != utf8.RUNE_ERROR {
		back(lexer);
	}
}

back :: proc(using lexer: ^Lexer) {
	//assert(last_rune_size != 0);
	offset -= last_rune_size;
	last_rune_size = 0;
}

get_rune :: proc(using lexer: ^Lexer) -> rune {
	r, i := utf8.decode_rune(file[offset..]);
	offset += i;
	last_rune_size = i;
	return r;
}

is_alpha :: proc(r: rune) -> bool {
	return (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z');
}

is_num :: proc(r: rune) -> bool {
	return (r >= '0' && r <= '9');
}

is_alnum :: proc(r: rune) -> bool {
	return is_alpha(r) || is_num(r);
}

get_token :: proc(using lexer: ^Lexer) -> Token {
	eat_whitespace(lexer);
	r := get_rune(lexer);
	if r == utf8.RUNE_ERROR {
		return Token{TokenType.EOF, "(EOF)"};
	}

	match r {
		case '.': {
			return Token{TokenType.Dot, "."};
		}
		case ':': {
			return Token{TokenType.Colon, ":"};
		}
		case ',': {
			return Token{TokenType.Comma, ","};
		}
		case '\n': {
			return Token{TokenType.Newline, "(newline)"};
		}
		case '"': {
			start := offset;
			r = get_rune(lexer);
			for r != utf8.RUNE_ERROR && r != '"' {
				r = get_rune(lexer);
			}

			str := string(file[start..offset-2]);
			return Token{TokenType.String, str};
		}
	}

	if is_num(r) {
		start := offset-1;

		old_r = r;
		r  = get_rune(lexer);

		// hexadecimal or binary
		if old_r == 0 {
			match r {
				case 'x': {
					start = offset;
					
				}
				case 'b': {

				}
			}
		}

		// normal integer
	}

	if is_alpha(r) {
		start := offset-1;

		r = get_rune(lexer);
		for r != utf8.RUNE_ERROR && (is_alnum(r) || r == '_') {
			r = get_rune(lexer);
		}
		back(lexer);

		ident := string(file[start.. offset-1]);
		return Token{TokenType.Ident, ident};
	}

	return Token{TokenType.Unknown, "(Unknown)"};
}

main :: proc() {
	parser := new(Parser);
	init_lexer(parser, "test.asm");

	tok := get_token(parser);
	for tok.type != TokenType.EOF {
		fmt.println(tok);
		tok = get_token(parser);
	}
}