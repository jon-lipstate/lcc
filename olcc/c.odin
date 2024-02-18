package lcc

FILE :: rawptr // TODO: CRT ALIAS

Coordinate :: struct {
	file: string,
	x, y: uint,
}
Value :: struct #raw_union {
	i: i32,
	u: u32,
	d: f64,
	p: rawptr,
	g: proc(),
}
XType :: struct {
	printed: bool, // unsigned printed:1;
	marked:  uint,
	typeno:  u16,
	xt:      rawptr,
}

Metrics :: struct {
	size, align, outofline: u8,
}

Interface_LITTLE_ENDIAN :: u32(1 << 0)
Interface_MULOPS_CALLS :: u32(1 << 1)
Interface_WANTS_CALLB :: u32(1 << 2)
Interface_WANTS_ARGB :: u32(1 << 3)
Interface_LEFT_TO_RIGHT :: u32(1 << 4)
Interface_WANTS_DAG :: u32(1 << 5)
Interface_UNSIGNED_CHAR :: u32(1 << 6)

Interface :: struct {
	char_metric:       Metrics,
	short_metric:      Metrics,
	int_metric:        Metrics,
	long_metric:       Metrics,
	longlong_metric:   Metrics,
	float_metric:      Metrics,
	double_metric:     Metrics,
	longdouble_metric: Metrics,
	ptr_metric:        Metrics,
	struct_metric:     Metrics,
	bits:              u32, // Replacing individual bit-fields with a single u32 for bit manipulation
	address:           proc(p, q: ^Symbol, n: i64),
	block_beg:         proc(env: ^Env),
	block_end:         proc(env: ^Env),
	def_address:       proc(p: ^Symbol),
	def_const:         proc(suffix, size: int, v: Value),
	def_string:        proc(n: int, s: cstring),
	def_symbol:        proc(p: ^Symbol),
	emit:              proc(n: ^Node),
	export:            proc(p: ^Symbol),
	function:          proc(f, args, locals: []^Symbol, is_vararg: int),
	gen:               proc(n: ^Node) -> ^Node,
	global:            proc(p: ^Symbol),
	import_:           proc(p: ^Symbol),
	local:             proc(p: ^Symbol),
	prog_beg:          proc(argc: int, argv: []cstring),
	prog_end:          proc(),
	segment:           proc(segment_id: int),
	space:             proc(n: int),
	stab_block:        proc(kind, level: int, syms: []^Symbol),
	stab_end:          proc(
		end: ^Coordinate,
		func: ^Symbol,
		coords: []^Coordinate,
		globals: []^Symbol,
		statics: []^Symbol,
	),
	stab_fend:         proc(f: ^Symbol, lineno: int),
	stab_init:         proc(filename: cstring, argc: int, argv: []cstring),
	stab_line:         proc(coord: ^Coordinate),
	stab_sym:          proc(p: ^Symbol),
	stab_type:         proc(p: ^Symbol),
	x:                 Xinterface,
}
Binding :: struct {
	name: string,
	ir:   ^Interface,
}
//
BINDINGS: []Binding
IR: ^Interface
//
Events :: struct {
	block_entry: List,
	block_exit:  List,
	entry:       List,
	exit:        List,
	returns:     List,
	points:      List,
	calls:       List,
	end:         List,
}
Node :: struct {
	op:    i16,
	count: i16,
	syms:  [3]^Symbol,
	kids:  [2]^Node,
	next:  ^Node,
	x:     Xnode,
}
Section :: enum {
	CODE = 1,
	BSS,
	DATA,
	LIT,
}
Arena :: enum {
	Perm,
	Func,
	Stmt,
}

List :: struct {
	x:    rawptr,
	next: ^List,
}
Code_Kind :: enum {
	Block_Beg,
	Block_End,
	Local,
	Address,
	Def_point,
	Label,
	Start,
	Gen,
	Jump,
	Switch,
}
Code :: struct {
	kind:       Code_Kind,
	prev, next: ^Code,
	u:          struct #raw_union {
		block:  struct {
			level:       int,
			locals:      [^]^Symbol,
			identifiers: ^Table,
			types:       ^Table,
			x:           Env,
		},
		begin:  ^Code,
		var:    ^Symbol,
		addr:   struct {
			sym:    ^Symbol,
			base:   ^Symbol,
			offset: int,
		},
		point:  struct {
			src:   Coordinate,
			point: int,
		},
		forest: ^Node,
		swtch:  struct {
			sym:    ^Symbol,
			table:  ^Symbol,
			deflab: ^Symbol,
			size:   int,
			values: ^int,
			labels: [^]^Symbol,
		},
	},
}
Swtch :: struct {
	sym:    ^Symbol,
	label:  int,
	deflab: ^Symbol,
	ncases: int,
	size:   int,
	values: ^int,
	labels: ^Symbol,
}

Symbol_STRUCT_ARG :: u8(1 << 0)
Symbol_ADDRESSED :: u8(1 << 1)
Symbol_COMPUTED :: u8(1 << 2)
Symbol_TEMPORARY :: u8(1 << 3)
Symbol_GENERATED :: u8(1 << 4)
Symbol_DEFINED :: u8(1 << 5)

Symbol :: struct {
	name:   string,
	scope:  int,
	src:    Coordinate,
	up:     ^Symbol,
	uses:   ^List,
	sclass: int,
	bits:   u8, // structarg:1, addressed:1; computed:1; temporary:1; generated:1; defined:1;
	type:   ^Type,
	ref:    f32,
	u:      struct #raw_union {
		l:       struct {
			label:      int,
			equated_to: ^Symbol,
		},
		s:       struct {
			bits:  u8, // cfields:1, vfields:1
			ftab:  ^Table, /*omit ??*/
			flist: ^Field,
		},
		value:   int,
		id_list: [^]^Symbol,
		limits:  struct {
			min, max: Value,
		},
		c:       struct {
			v:   Value,
			loc: ^Symbol,
		},
		f:       struct {
			pt:     Coordinate,
			label:  int,
			ncalls: int,
			callee: ^^Symbol,
		},
		seg:     int,
		alias:   ^Symbol,
		t:       struct {
			cse:     ^Node,
			replace: int,
			next:    ^Symbol,
		},
	},
	x:      Xsymbol,
}

Levels :: enum int {
	Constant = 1,
	Label,
	Global,
	Param,
	Local,
}

Tree :: struct {
	op:   int,
	type: ^Type,
	kids: [2]^Tree,
	node: ^Node,
	u:    struct #raw_union {
		v:     Value,
		sym:   ^Symbol,
		field: ^Field,
	},
}
SOMETHING :: enum {
	AND   = 38 << 4,
	NOT   = 39 << 4,
	OR    = 40 << 4,
	COND  = 41 << 4,
	RIGHT = 42 << 4,
	FIELD = 43 << 4,
}

Type :: struct {
	op:    Symbol_Id,
	type:  ^Type,
	align: int,
	size:  int,
	u:     struct #raw_union {
		sym: ^Symbol,
		f:   struct {
			old_style: bool, //  unsigned oldstyle:1;
			proto:     ^^Type,
		},
	},
	x:     XType,
}

Field :: struct {
	name:     string,
	type:     ^Type,
	offset:   int,
	bit_size: int, //short
	lsb:      int, //short
	next:     ^Field,
}

/////////////////
SRC: Coordinate
AFlag: int
