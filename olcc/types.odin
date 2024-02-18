package lcc

//////
TYPE_TABLE_SIZE :: 128
//////
TYPE_TABLE: [TYPE_TABLE_SIZE]^Type_Entry
MAX_LEVEL: int
POINTER_SYM: ^Symbol

CHAR_TYPE: ^Type /* char */
DOUBLE_TYPE: ^Type /* double */
FLOAT_TYPE: ^Type /* float */
INT_TYPE: ^Type /* signed int */
LONGDOUBLE: ^Type /* long double */
LONG_TYPE: ^Type /* long */
LONG_LONG: ^Type /* long long */
SHORT_TYPE: ^Type /* signed short int */
SIGNEDCHAR: ^Type /* signed char */
UNSIGNED_CHAR: ^Type /* unsigned char */
UNSIGNED_LONG: ^Type /* unsigned long int */
UNSIGNED_LONG_LONG: ^Type /* unsigned long long int */
UNSIGNED_SHORT: ^Type /* unsigned short int */
UNSIGNED_TYPE: ^Type /* unsigned int */
FUNCP_TYPE: ^Type /* void (*)() */
CHARP_TYPE: ^Type /* char* */
VOIDP_TYPE: ^Type /* void* */
VOID_TYPE: ^Type /* basic types: void */
UNSIGNED_PTR: ^Type /* unsigned type to hold void* */
SIGNED_PTR: ^Type /* signed type to hold void* */
WIDE_CHAR: ^Type /* unsigned type that represents wchar_t */
//////
@(private)
Type_Entry :: struct {
	type: Type,
	next: ^Type_Entry,
}
//////
xxinit :: proc(op: int, name: string, m: Metrics) -> ^Type {
	unimplemented()
}
type :: proc(op: int, ty: ^Type, size: int, align: int, sym: rawptr) -> ^Type {
	unimplemented()
}
type_init :: proc(args: []string) {
	unimplemented()
}
rmtypes :: proc(level: int) {
	if MAX_LEVEL >= level {
		MAX_LEVEL = 0
		for i := 0; i < len(TYPE_TABLE); i += 1 {
			tq := &TYPE_TABLE[i]

			for tn := tq^; tn != nil; tn = tq^ {
				if tn.type.op == .FUNCTION {
					tq = &tn.next
				} else if tn.type.u.sym != nil && tn.type.u.sym.scope >= level {
					tq^ = tn.next
				} else {
					if tn.type.u.sym != nil && tn.type.u.sym.scope > MAX_LEVEL {
						MAX_LEVEL = tn.type.u.sym.scope
					}
					tq = &tn.next
				}
			}
		}
	}
}
ptr :: proc(ty: ^Type) -> ^Type {
	unimplemented()
}
deref :: proc(ty: ^Type) -> ^Type {
	unimplemented()
}
array :: proc(ty: ^Type, n: int, a: int) -> ^Type {
	unimplemented()
}
atop :: proc(ty: ^Type) -> ^Type {
	unimplemented()
}
qual :: proc(op: int, ty: ^Type) -> ^Type {
	unimplemented()
}
func :: proc(ty: ^Type, proto: ^^Type, style: int) -> ^Type {
	unimplemented()
}
freturn :: proc(ty: ^Type) -> ^Type {
	unimplemented()
}
variadic :: proc(ty: ^Type) -> ^Type {
	unimplemented()
}
new_struct :: proc(op: int, tag: string) -> ^Type {
	unimplemented()
}
new_field :: proc(name: string, ty: ^Type, fty: ^Type) -> ^Field {
	unimplemented()
}
eq_type :: proc(a, b: ^Type, ret: int) -> int {
	unimplemented()
}
promote :: proc(ty: ^Type) -> ^Type {unimplemented()}
signed_int :: proc(ty: ^Type) -> ^Type {unimplemented()}
compose :: proc(a, b: ^Type) -> ^Type {unimplemented()}
ttob :: proc(ty: ^Type) -> int {unimplemented()}
btot :: proc(op: int, size: int) -> ^Type {unimplemented()}
has_proto :: proc(ty: ^Type) -> int {unimplemented()}

/* fieldlist - construct a flat list of fields in type ty */
field_list :: proc(ty: ^Type) -> [^]Field {unimplemented()}
/* fieldref - find field name of type ty, return entry */
field_ref :: proc(name: string, ty: ^Type) -> ^Type {unimplemented()}
/* ftype - return a function type for rty function (ty,...)' */
ftype :: proc(rty: ^Type, args: ..any) -> ^Type {unimplemented()}
/* isfield - if name is a field in flist, return pointer to the field structure */
is_field :: proc(name: string, flist: [^]Field) -> ^Type {unimplemented()}
/* outtype - output type ty */
out_type :: proc(ty: ^Type, f: ^FILE) {unimplemented()}
/* printdecl - output a C declaration for symbol p of type ty */
print_decl :: proc(p: ^Symbol, ty: ^Type) {unimplemented()}
/* printproto - output a prototype declaration for function p */
print_proto :: proc(p: ^Symbol, callee: []^Symbol) {unimplemented()}
/* prtype - print details of type ty on f with given indent */
pr_type :: proc(ty: ^Type, f: ^FILE, indent: int, mark: uint) {unimplemented()}
/* printtype - print details of type ty on fd */
print_type :: proc(ty: ^Type, fd: int) {unimplemented()}
/* typestring - return ty as C declaration for str, which may be "" */
type_string :: proc(ty: ^Type, str: string) -> string {unimplemented()}
