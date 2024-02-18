package lcc
Xinterface :: struct {
	max_unaligned_load: u8,
	rmap:               proc(i: int) -> ^Symbol,
	blkfetch:           proc(size: int, off: int, reg: int, tmp: int),
	blkstore:           proc(size: int, off: int, reg: int, tmp: int),
	blkloop:            proc(dreg: int, doff: int, sreg: int, soff: int, size: int, tmps: []int),
	_label:             proc(n: ^Node),
	_rule:              proc(p: rawptr, i: int) -> int,
	_nts:               ^^i16,
	_kids:              proc(n: ^Node, i: int, m: ^^Node),
	_string:            ^string,
	_templates:         ^string,
	_isinstruction:     string,
	_ntname:            ^string,
	emit2:              proc(n: ^Node),
	doarg:              proc(n: ^Node),
	target:             proc(n: ^Node),
	clobber:            proc(n: ^Node),
}

Xnode_LISTED :: 1 << 0
Xnode_REGISTERED :: 1 << 1
Xnode_EMITTED :: 1 << 2
Xnode_COPY :: 1 << 3
Xnode_EQUATABLE :: 1 << 4
Xnode_SPILLS :: 1 << 5
Xnode_MAY_RECALC :: 1 << 6
Xnode :: struct {
	bits:       u8,
	// unsigned listed:1;
	// unsigned registered:1;
	// unsigned emitted:1;
	// unsigned copy:1;
	// unsigned equatable:1;
	// unsigned spills:1;
	// unsigned mayrecalc:1;
	state:      rawptr,
	inst:       i16,
	kids:       [3]^Node,
	prev, next: ^Node,
	prevuse:    ^Node,
	argno:      i16,
}
Regnode :: struct {
	vbl:    ^Symbol,
	set:    i16,
	number: i16,
	mask:   u32,
}
// enum { IREG=0, FREG=1 };
Xsymbol :: struct {
	name:     string,
	eaddr:    uint, /* omit */
	offset:   int,
	lastuse:  ^Node,
	usecount: int,
	regnode:  ^Regnode,
	wildcard: ^Symbol,
}
// enum { RX=2 };
Env :: struct {
	offset:   int,
	freemask: [2]u32,
}
