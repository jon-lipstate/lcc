package occ

import "core:fmt"
import "core:os"
// TODO: Support UTF-8 to be C11 compliant
Tokenizer :: struct {
	// Immutable data
	path:       string,
	src:        string,
	// Tokenizing state
	ch:         u8,
	offset:     int,
	line_count: int,
}

init_tokenizer :: proc(path: string) -> Tokenizer {
	src, ok := os.read_entire_file(path)
	fmt.assertf(ok, "Failed to read: %v", path)
	t := Tokenizer {
		src        = string(src),
		path       = path,
		line_count = len(src) > 0 ? 1 : 0,
		ch         = len(src) > 0 ? src[0] : 0,
	}
	return t
}

at_eof :: proc(t: ^Tokenizer) -> bool {
	return t.offset >= len(t.src)
}

scan :: proc(t: ^Tokenizer) -> Token {
	skip_whitespace(t)
	if t.offset >= len(t.src) {return Token{kind = .EOF}}

	start := t.offset
	lit: string
	kind := Token_Kind.Invalid
	pos := get_pos(t)

	trivial_parse := true
	switch t.ch {
	case ',':
		kind = .Comma
	case '(':
		kind = .Open_Paren
	case ')':
		kind = .Close_Paren
	case '[':
		kind = .Open_Bracket
	case ']':
		kind = .Close_Bracket
	case '{':
		kind = .Open_Brace
	case '}':
		kind = .Close_Brace
	case ':':
		kind = .Colon
	case ';':
		kind = .Semicolon
	case '?':
		kind = .Question_Mark
	case '~':
		kind = .Tilde
	case:
		trivial_parse = false
	}
	if trivial_parse {
		advance_char(t)
		lit = t.src[start:t.offset]
		return Token{text = lit, kind = kind, pos = pos}
	}
	/////
	medium_parse := true
	n_consume := 1
	switch t.ch {
	case '+':
		switch peek_char(t) {
		case:
			kind = .Plus
		case '=':
			kind = .Assignment_Add
			n_consume += 1
		case '+':
			kind = .Increment
			n_consume += 1
		}
	case '-':
		next := peek_char(t)
		switch peek_char(t) {
		case:
			kind = .Minus
		case '>':
			kind = .Arrow
			n_consume += 1
		case '-':
			kind = .Decrement
			n_consume += 1
		case '=':
			kind = .Assignment_Subtract
			n_consume += 1
		case '0' ..= '9':
			return scan_number(t)
		}
	case '*':
		switch peek_char(t) {
		case:
			kind = .Asterisk
		case '>':
			kind = .Assignment_Multiply
			n_consume += 1
		}
	case '/':
		switch peek_char(t) {
		case:
			kind = .Slash
		case '=':
			kind = .Assignment_Divide
			n_consume += 1
		case '/':
			kind = .Single_Line_Comment
			for t.ch != '\n' {advance_char(t)}
			end := t.offset
			if t.src[t.offset - 1] == '\r' {
				end -= 1
			}
			lit = t.src[start:end]

			return Token{pos = pos, kind = kind, text = lit}
		case '*':
			advance_char(t)
			kind = .Multi_Line_Comment
			for {
				if t.ch == '*' && peek_char(t) == '/' {
					advance_char(t)
					advance_char(t)
					break
				}
				advance_char(t)
			}
			lit = t.src[start:t.offset]
			return Token{pos = pos, kind = kind, text = lit}
		}
	case '%':
		switch peek_char(t) {
		case:
			kind = .Percent
		case '=':
			kind = .Assignment_Modulus
			n_consume += 1
		}
	case '^':
		switch peek_char(t) {
		case:
			kind = .Caret
		case '=':
			kind = .Assignment_Xor
			n_consume += 1
		}
	case '|':
		switch peek_char(t) {
		case:
			kind = .Vertical_Bar
		case '=':
			kind = .Assignment_Or
			n_consume += 1
		case '|':
			kind = .Logical_Or
			n_consume += 1
		}
	case '&':
		switch peek_char(t) {
		case:
			kind = .Ampersand
		case '=':
			kind = .Assignment_And
			n_consume += 1
		case '&':
			kind = .Logical_And
			n_consume += 1
		}
	case '!':
		switch peek_char(t) {
		case:
			kind = .Exclamation
		case '=':
			kind = .Not_Equal
			n_consume += 1
		}
	case '=':
		switch peek_char(t) {
		case:
			kind = .Assignment
		case '=':
			kind = .Equal
			n_consume += 1
		}
	case '.':
		switch peek_char(t) {
		case:
			kind = .Dot
		case '.':
			assert(peek_char(t, 2) == '.', "Got `..`, expected a 3rd dot for ellipsis")
			kind = .Ellipsis
			n_consume += 2
		}
	case '<':
		switch peek_char(t) {
		case:
			kind = .Less_Than
		case '=':
			kind = .Less_Than_Or_Equal
			n_consume += 1
		case '<':
			if peek_char(t, 2) == '=' {
				kind = .Assignment_Left_Shift
				n_consume += 2
			} else {
				kind = .Left_Shift
				n_consume += 1
			}
		}
	case '>':
		switch peek_char(t) {
		case:
			kind = .Greater_Than
		case '=':
			kind = .Greater_Than_Or_Equal
			n_consume += 1
		case '>':
			if peek_char(t, 2) == '=' {
				kind = .Assignment_Right_Shift
				n_consume += 2
			} else {
				kind = .Right_Shift
				n_consume += 1
			}
		}
	case '#':
		kind = .Directive
		ch := advance_char(t)
		n_consume = 0
		for !at_eof(t) {
			if ch == '\n' {
				break
			}
			ch = advance_char(t)
		}

	case '"':
		kind = .String_Lit
		ch := advance_char(t) // consume starting `"`, 
		n_consume = 0 // manage advancing ourselves
		for !at_eof(t) {
			if ch == '\\' && peek_char(t) == '"' {
				advance_char(t) // consume \
				advance_char(t) // consume "
			}
			if ch == '"' {
				advance_char(t)

				break
			}
			ch = advance_char(t)
		}
	case '\'':
		kind = .Char_Lit
		advance_char(t) // consume starting `'`, 
		n_consume = 0 // manage advancing ourselves
		if t.ch == '\\' {
			switch peek_char(t) {
			case 't', 'n', 'r', '\\', '\'', '\"', '0':
				advance_char(t)
				advance_char(t)
			case:
				fmt.printf("not handled char: '%v' '%v'\n", rune(t.ch), rune(peek_char(t)))
				unimplemented("escape parse not impl")
			}
		} else {
			// normal char lit
			advance_char(t)
			advance_char(t)
		}

	case:
		medium_parse = false
	}
	if medium_parse {
		for _ in 0 ..< n_consume {advance_char(t)}
		sub_r := t.src[t.offset - 1] == '\r' ? 1 : 0 // remove \r if last char
		lit = t.src[start:t.offset - sub_r]
		return Token{pos = pos, kind = kind, text = lit}
	}
	//////
	if is_digit(t.ch) {
		return scan_number(t)
	} else if is_alpha(t.ch) {
		for is_alpha(t.ch) || is_digit(t.ch) {advance_char(t)}
		lit = t.src[start:t.offset]
		if lit in KEYWORDS {
			kind = KEYWORDS[lit]
		} else {
			kind = .Identifier
		}
		return Token{kind = kind, text = lit, pos = pos}
	} else {
		fmt.panicf("Failed to parse <%v>", rune(t.ch))
	}
	fmt.panicf("Failed to parse <%v>", rune(t.ch))
}

scan_number :: proc(t: ^Tokenizer) -> Token {
	// do not support nutty hex-floats: double foo() { return 0x1.570a3d70a3d71p-1; }
	start := t.offset
	pos := get_pos(t)
	is_float := false

	if t.ch == '-' {advance_char(t)}
	// integer-part:
	for is_digit(t.ch) {advance_char(t)}
	if t.ch == '.' {
		is_float = true
		advance_char(t)
		for is_digit(t.ch) {advance_char(t)}
	}
	if t.ch == 'e' || t.ch == 'E' {
		is_float = true
		advance_char(t)
		if t.ch == '+' || t.ch == '-' {
			advance_char(t)
		}
		assert(is_digit(t.ch), "Scientific Notation requires at least one digit past the `E`")
		for is_digit(t.ch) {advance_char(t)}
	}

	if (!is_float) {
		// Integer literal suffixes
		for t.ch == 'u' || t.ch == 'U' || t.ch == 'l' || t.ch == 'L' {
			advance_char(t)
		}
	} else {
		// Float literal suffixes
		if (t.ch == 'f' || t.ch == 'F' || t.ch == 'l' || t.ch == 'L') {
			advance_char(t)
		}
	}

	kind: Token_Kind = is_float ? .Float_Lit : .Integer_Lit
	return Token{kind = kind, text = t.src[start:t.offset], pos = pos}
}

get_pos :: proc(t: ^Tokenizer) -> Pos {
	// file   = t.path,
	return Pos{offset = t.offset, line = t.line_count}
}
advance_char :: proc(t: ^Tokenizer) -> u8 {
	if t.ch == '\n' {
		t.line_count += 1
	}
	if t.offset >= len(t.src) - 1 {
		t.offset += 1
		t.ch = 0
	} else {
		t.offset += 1
		t.ch = t.src[t.offset]
	}
	return t.ch
}

peek_char :: proc(t: ^Tokenizer, lookahead := 1) -> u8 {
	if t.offset + lookahead >= len(t.src) {return 0}
	return t.src[t.offset + lookahead]
}

skip_whitespace :: proc(t: ^Tokenizer) {
	for {
		switch t.ch {
		case ' ', '\t', '\r', '\n':
			advance_char(t)
		case:
			return
		}
	}
}

is_digit :: proc(ch: u8) -> bool {
	return '0' <= ch && ch <= '9'
}
is_alpha :: proc(ch: u8) -> bool {
	is_lower := 'a' <= ch && ch <= 'z'
	is_upper := 'A' <= ch && ch <= 'Z'
	return is_lower || is_upper || '_' == ch
}


tokenize_directive :: proc(directive: Token, buf: ^[16]Token) -> []Token {
	fmt.assertf(directive.kind == .Directive, "Expected a directive, got %v", directive.kind)
	assert(directive.text[0] == '#', "directives must start with '#'")
	tmp := Tokenizer {
		src        = directive.text[1:],
		line_count = directive.pos.line,
		ch         = directive.text[1],
	}
	n_tokens := 0
	for !at_eof(&tmp) {
		buf[n_tokens] = scan(&tmp)
		n_tokens += 1
	}
	has_eof := buf[n_tokens - 1].kind == .EOF ? 1 : 0
	return buf[:n_tokens - has_eof]
}
