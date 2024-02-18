package lcc

import "core:os"

MAX_LINE :: 512
BUF_SIZE :: 4096

BSIZE: int
BUFFER: [MAX_LINE + 1 + BUF_SIZE + 1]u8
CP: ^u8 // current char
FILE_PATH: string // current file name
FIRST_FILE: string // first file
LIMIT: ^u8 // last-char+1
LINE: ^u8 // current line
LINE_NO: int // line# of current line

// next_line :: proc() {
// 	for {
// 		if uintptr(CP) >= uintptr(LIMIT) {
// 			fill_buf()
// 			if uintptr(CP) >= uintptr(LIMIT) {CP = LIMIT}
// 			if uintptr(CP) == uintptr(LIMIT) {return}
// 		} else {
// 			LINE_NO += 1
// 			for LINE = CP; CP^ == ' ' || CP^ == '\t'; CP = ptr_add(CP, 1) {}
// 			if CP^ == '#' {
// 				re_synch()
// 				next_line()
// 			}
// 		}
// 		if !(CP^ == '\n' && CP == LIMIT) {break}
// 	}
// }

// fill_buf :: proc() {
// 	if BSIZE == 0 {return}
// 	if uintptr(CP) >= uintptr(LIMIT) {
// 		CP = &BUFFER[MAX_LINE + 1]
// 	} else {
// 		n := ptr_sub(LIMIT, CP)
// 		s := ptr_sub(&BUFFER[MAX_LINE + 1], n)
// 		assert(uintptr(s) >= uintptr(&BUFFER[0]))
// 		LINE = ptr_sub(s, ptr_sub(CP, LINE))
// 		for uintptr(CP) < uintptr(LIMIT) {
// 			s^ = CP^
// 			s = ptr_add(s, 1)
// 			CP = ptr_add(CP, 1)
// 		}
// 		CP = ptr_sub(&BUFFER[MAX_LINE + 1], n)
// 	}
//     if 
// }

input_init :: proc(args: []string) {
	@(static)
	inited := false
	if inited {return}
	inited = true
	// main_init(args)
	unimplemented()
}

/* ident - handle #ident "string" */
ident :: proc() {
	// for CP^ != '\n' && CP^ != 0 {
	//     CP++
	// }
	unimplemented()
}
pragma :: proc() {
	// t: Token 
	// token: string 
	// tsym: ^Symbol 
	// src: Coordinate 
	// t = get_tok()
	// if t == ID && token == "ref" {
	// 	for {
	// 		// Skip spaces and tabs
	// 		for cp^ == ' ' || cp^ == '\t' {
	// 			cp = ptr_add(cp, 1)
	// 		}

	// 		if cp^ == '\n' || cp^ == 0 {
	// 			break
	// 		}
	// 		t = get_tok()
	// 		if t == Symbol_Id.ID && tsym != nil {
	// 			tsym.ref += 1
	// 			use(tsym, src)
	// 		}
	// 	}
	// }
	unimplemented()
}

resynch :: proc() {
	unimplemented()
}
