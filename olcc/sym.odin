package lcc

TABLE_HASH_SIZE :: 256
/////
CONSTANTS := &Table{level = int(Levels.Constant)}
EXTERNALS := &Table{level = int(Levels.Global)}
IDENTIFIERS := &Table{level = int(Levels.Global)}
GLOBALS := &Table{level = int(Levels.Global)}
TYPES := &Table{level = int(Levels.Global)}
LABELS: ^Table
LEVEL: Levels = .Global
TEMP_ID: int
LOCI: ^List
SYMBOLS: ^List
/////
Table :: struct {
	level:    int,
	previous: ^Table,
	buckets:  [TABLE_HASH_SIZE]^Entry,
	all:      ^Symbol,
}
Entry :: struct {
	sym:  Symbol,
	next: ^Entry,
}
/////
new_table :: proc(arena: Arena) -> ^Table {
	buf := allocate(size_of(Table), arena)
	tbl := transmute(^Table)buf
	tbl^ = {}
	return tbl
}
table :: proc(tp: ^Table, level: int) -> ^Table {
	tbl := new_table(.Func)
	tbl.previous = tp
	tbl.level = level
	if tp != nil {tbl.all = tp.all}
	return tbl
}
foreach :: proc(tbl: ^Table, level: int, apply: proc(sym: Symbol, cl: rawptr), cl: rawptr) {
	assert(tbl != nil)
	tbl := tbl
	for tbl != nil && tbl.level > level {
		tbl = tbl.previous
	}
	if tbl != nil && tbl.level == level {
		prev_src := SRC // src is a GLOBAL
		for p := tbl.all; p != nil && p.scope == level; p = p.up {
			SRC = p.src
			apply(p^, cl)
		}
		SRC = prev_src
	}
}
enter_scope :: proc() {
	LEVEL = cast(Levels)(int(LEVEL) + 1)
	if LEVEL == .Local {
		TEMP_ID = 0
	}
}
exit_scope :: proc() {
	rmtypes(int(LEVEL))
	if TYPES.level == int(LEVEL) {
		TYPES = TYPES.previous
	}
	if IDENTIFIERS.level == int(LEVEL) {
		if AFlag >= 2 {
			n := 0
			p: ^Symbol
			for p = IDENTIFIERS.all; p != nil && p.scope == int(LEVEL); p = p.up {
				n += 1
				if n > 127 {
					warning("More than 127 identifiers declared in a block\n")
					break
				}
			}
		}
		IDENTIFIERS = IDENTIFIERS.previous
	}
	assert(LEVEL >= .Global)
	LEVEL = cast(Levels)(int(LEVEL) - 1)
}
install :: proc(name: string, tpp: ^^Table, level: int, arena: Arena) -> ^Symbol {
	tp := tpp^
	p: ^Entry
	h := hash(name) % TABLE_HASH_SIZE
	assert(int(LEVEL) == 0 || int(LEVEL) >= tp.level)
	if int(LEVEL) > 0 && tp.level < int(LEVEL) {
		tpp^ = table(tp, level)
		tp = tpp^
	}
	p = transmute(^Entry)allocate(size_of(Entry), arena)
	p.sym.name = name
	p.sym.scope = int(LEVEL)
	p.sym.up = tp.all
	tp.all = &p.sym
	p.next = tp.buckets[h]
	tp.buckets[h] = p
	return &p.sym
}
relocate :: proc(name: string, src: ^Table, dst: ^Table) -> ^Symbol {
	h := hash(name) % TABLE_HASH_SIZE
	q: ^^Entry = &src.buckets[h]
	for ; q^ != nil; q = &q^.next {if name == q^.sym.name {break}}
	assert(q^ != nil)
	// remove from src hash-chain:
	p := q^ // stash current entry
	q^ = q^.next // set ptr next to skip current

	r: ^^Symbol
	for r = &src.all; r^ != nil && r^ != &p.sym; r = &(r^).up {}
	assert(r^ == &p.sym)
	//insert entry into dst hash chain and list of symbols:
	p.next = dst.buckets[h]
	dst.buckets[h] = p
	p.sym.up = dst.all
	dst.all = &p.sym

	return &p.sym
}
lookup :: proc(name: string, tbl: ^Table) -> ^Symbol {
	h := hash(name) % TABLE_HASH_SIZE
	assert(tbl != nil)
	tbl := tbl
	for tbl != nil {
		for p := tbl.buckets[h]; p != nil; p = p.next {
			if name == p.sym.name {return &p.sym}
		}
		tbl = tbl.previous
	}
	return nil
}
gen_label :: proc(n: int) -> int {
	@(static)
	label: int = 1
	label += n
	return label - n
}
find_label :: proc(label: int) -> ^Symbol {
	h := hash(label) % TABLE_HASH_SIZE
	p := LABELS.buckets[h]
	for ; p != nil; p = p.next {
		if label == p.sym.u.l.label {return &p.sym}
	}
	p = transmute(^Entry)allocate(size_of(Entry), .Func, true)
	p.sym.name = intern_number_as_string(label).str
	p.sym.scope = int(Levels.Label)
	p.sym.up = LABELS.all
	LABELS.all = &p.sym
	p.next = LABELS.buckets[h]
	LABELS.buckets[h] = p
	p.sym.bits |= Symbol_GENERATED
	p.sym.u.l.label = label
	IR.def_symbol(&p.sym)
	return &p.sym
}
constant :: proc(ty: ^Type, v: Value) -> ^Symbol {
	unimplemented()
}
int_const :: proc(n: int) -> ^Symbol {
	unimplemented()
}

gen_ident :: proc(scls: int, ty: ^Type, level: int) -> ^Symbol {
	unimplemented()
}

temporary :: proc(scls: int, ty: ^Type) -> ^Symbol {
	unimplemented()
}
new_temp :: proc(sclass: int, tc: int, size: int) -> ^Symbol {
	unimplemented()
}
all_symbols :: proc(tp: ^Table) -> ^Symbol {
	unimplemented()
}
locus :: proc(tp: ^Table, cp: ^Coordinate) {
	unimplemented()
}
use :: proc(p: ^Symbol, src: Coordinate) {
	unimplemented()
}
/* findtype - find type ty in identifiers */
find_type :: proc(ty: ^Type) -> ^Symbol {
	unimplemented()
}
/* mkstr - make a string constant */
mk_str :: proc(str: string) -> ^Symbol {
	unimplemented()
}
/* mksymbol - make a symbol for name, install in &globals if sclass==EXTERN */
mk_symbol :: proc(sclass: int, name: string, ty: ^Type) -> ^Symbol {
	unimplemented()
}
/* vtoa - return string for the constant v of type ty */
vtoa :: proc(ty: ^Type, v: Value) -> string {
	unimplemented()
}
