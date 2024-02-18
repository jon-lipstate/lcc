package occ

Token :: struct {
	kind: Token_Kind,
	text: string,
	pos:  Pos,
}

Pos :: struct {
	// file:   string,
	offset: int, // starting at 0
	line:   int, // starting at 1
	column: int, // starting at 1
}

Token_Kind :: enum {
	Invalid,
	EOF,
	Single_Line_Comment,
	Multi_Line_Comment,
	Identifier,
	Integer_Lit,
	Float_Lit,
	String_Lit,
	Char_Lit,
	//Punct
	Open_Bracket, // [
	Close_Bracket, // ]
	Open_Paren, // (
	Close_Paren, // )
	Open_Brace, // {
	Close_Brace, // }
	Dot, // .
	Arrow, // ->
	Increment, // ++
	Decrement, // --
	Ampersand, // &
	Asterisk, // *
	Plus, // +
	Minus, // -
	Tilde, // ~
	Exclamation, // !
	Slash, // /
	Percent, // %
	Left_Shift, // <<
	Right_Shift, // >>
	Less_Than, // <
	Greater_Than, // >
	Less_Than_Or_Equal, // <=
	Greater_Than_Or_Equal, // >=
	Equal, // ==
	Not_Equal, // !=
	Caret, // ^
	Vertical_Bar, // |
	Logical_And, // &&
	Logical_Or, // ||
	Question_Mark, // ?
	Colon, // :
	Semicolon, // ;
	Ellipsis, // ...
	//
	Assignment, // =
	Assignment_Divide, // /=
	Assignment_Multiply, // *=
	Assignment_Modulus, // %=
	Assignment_Add, // +=
	Assignment_Subtract, // -=
	Assignment_Left_Shift, // <<=
	Assignment_Right_Shift, // >>=
	Assignment_And, // &=
	Assignment_Xor, // ^=
	Assignment_Or, // |=
	//
	Comma, // ,
	Hash, // #
	Directive,

	//Keywords
	Keyword_auto,
	Keyword_break,
	Keyword_case,
	Keyword_char,
	Keyword_const,
	Keyword_continue,
	Keyword_default,
	Keyword_do,
	Keyword_double,
	Keyword_else,
	Keyword_enum,
	Keyword_extern,
	Keyword_float,
	Keyword_for,
	Keyword_goto,
	Keyword_if,
	Keyword_inline,
	Keyword_int,
	Keyword_long,
	Keyword_register,
	Keyword_restrict,
	Keyword_return,
	Keyword_short,
	Keyword_signed,
	Keyword_sizeof,
	Keyword_static,
	Keyword_struct,
	Keyword_switch,
	Keyword_typedef,
	Keyword_union,
	Keyword_unsigned,
	Keyword_void,
	Keyword_volatile,
	Keyword_while,
	Keyword__Alignas,
	Keyword__Alignof,
	Keyword__Atomic,
	Keyword__Bool,
	Keyword__Complex,
	Keyword__Embed,
	Keyword__Generic,
	Keyword__Imaginary,
	Keyword__Pragma,
	Keyword__Noreturn,
	Keyword__Static_assert,
	Keyword__Thread_local,
	Keyword__Typeof,
	Keyword__Vector,
	Keyword___asm__,
	Keyword___attribute__,
	Keyword___cdecl,
	Keyword___stdcall,
	Keyword___declspec,
}
KEYWORDS := map[string]Token_Kind {
	"auto"           = .Keyword_auto,
	"break"          = .Keyword_break,
	"case"           = .Keyword_case,
	"char"           = .Keyword_char,
	"const"          = .Keyword_const,
	"continue"       = .Keyword_continue,
	"default"        = .Keyword_default,
	"do"             = .Keyword_do,
	"double"         = .Keyword_double,
	"else"           = .Keyword_else,
	"enum"           = .Keyword_enum,
	"extern"         = .Keyword_extern,
	"float"          = .Keyword_float,
	"for"            = .Keyword_for,
	"goto"           = .Keyword_goto,
	"if"             = .Keyword_if,
	"inline"         = .Keyword_inline,
	"int"            = .Keyword_int,
	"long"           = .Keyword_long,
	"register"       = .Keyword_register,
	"restrict"       = .Keyword_restrict,
	"return"         = .Keyword_return,
	"short"          = .Keyword_short,
	"signed"         = .Keyword_signed,
	"sizeof"         = .Keyword_sizeof,
	"static"         = .Keyword_static,
	"struct"         = .Keyword_struct,
	"switch"         = .Keyword_switch,
	"typedef"        = .Keyword_typedef,
	"union"          = .Keyword_union,
	"unsigned"       = .Keyword_unsigned,
	"void"           = .Keyword_void,
	"volatile"       = .Keyword_volatile,
	"while"          = .Keyword_while,
	"_Alignas"       = .Keyword__Alignas,
	"_Alignof"       = .Keyword__Alignof,
	"_Atomic"        = .Keyword__Atomic,
	"_Bool"          = .Keyword__Bool,
	"_Complex"       = .Keyword__Complex,
	"_Embed"         = .Keyword__Embed,
	"_Generic"       = .Keyword__Generic,
	"_Imaginary"     = .Keyword__Imaginary,
	"_Pragma"        = .Keyword__Pragma,
	"_Noreturn"      = .Keyword__Noreturn,
	"_Static_assert" = .Keyword__Static_assert,
	"_Thread_local"  = .Keyword__Thread_local,
	"_Typeof"        = .Keyword__Typeof,
	"_Vector"        = .Keyword__Vector,
	"__asm__"        = .Keyword___asm__,
	"__attribute__"  = .Keyword___attribute__,
	"__cdecl"        = .Keyword___cdecl,
	"__stdcall"      = .Keyword___stdcall,
	"__declspec"     = .Keyword___declspec,
}
