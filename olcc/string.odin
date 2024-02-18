package lcc

import "core:math/bits"
I64_MIN :: bits.I64_MIN
I64_MAX :: bits.I64_MAX

Interned_String :: struct {
	str:  string,
	next: ^Interned_String,
}

BUCKET_COUNT :: 1024
BUCKETS: [BUCKET_COUNT]^Interned_String
RCSID := "$Id$"

hash :: proc {
	hash_string,
	hash_buf,
	hash_int,
}
hash_int :: proc(#any_int v: int) -> u32 {
	h := u32(2166136261)

	switch {
	case size_of(v) <= 4:
		h ~= u32(v)
		h *= 16777619
		return h
	case size_of(v) == 8:
		h ~= u32(v & 0xFFFFFFFF)
		h *= 16777619

		h ~= u32((v >> 32) & 0xFFFFFFFF)
		h *= 16777619
		return h
	case:
		unimplemented("unhandled size")

	}
	unreachable()
}
hash_buf :: proc(buf: []u8) -> u32 {
	h := u32(2166136261)
	for b in buf {
		h ~= u32(b)
		h *= 16777619
	}
	return h
}
//fnv1a
hash_string :: proc(str: string) -> u32 {
	return hash_buf(transmute([]u8)str)
}

string_ :: intern_string
stringn :: intern_string
intern_string :: proc(str: cstring) -> ^Interned_String {
	// get string length:
	length: int
	s: [^]u8 = transmute([^]u8)str
	for s[length] != 0 {length += 1}

	// find which index it should be in:
	src_buf := (transmute([^]u8)str)[:length]
	h: u32 = hash_string(string(src_buf))
	index := h % BUCKET_COUNT

	// see if pre-exists in that index:
	for p := BUCKETS[index]; p != nil; p = p.next {
		if p.str == string(src_buf) {
			return p // found exact match
		}
	}

	// NOTE: this doesnt quite align to lcc's static allocation strategy
	// static char *next, *strlimit;
	// TODO: come back and harmonize it
	// lcc strings internally manages data via pages (4k bytes) using next and str-limit. rework arena to hand it the Block itself
	@(static)
	current_block: ^Block

	// If not found, create a new interned string
	new_str: ^Interned_String = transmute(^Interned_String)allocate(
		size_of(Interned_String),
		.Perm,
	)
	buf_size := 1 * (length + 1)
	str_buf := allocate(uint(buf_size), .Perm)[:buf_size]
	new_str.str = transmute(string)str_buf
	copy(src_buf, str_buf)
	str_buf[length] = 0 // set the \0

	// update SLL:
	new_str.next = BUCKETS[index]
	BUCKETS[index] = new_str

	return new_str
}

stringd :: intern_number_as_string
intern_number_as_string :: proc(n: int) -> ^Interned_String {
	buf: [25]u8
	idx := len(buf) - 1 // each write below pre-subtracts leaving last elm at \0
	tmp: u64 = u64(n)

	switch {
	case n == 0:
		idx -= 1
		buf[idx] = '0'
	case n == I64_MIN:
		tmp = u64(I64_MAX) + 1
	case n < 0:
		tmp = u64(-n) // Convert to positive equivalent for processing
	}

	// Convert number to string from the back
	for tmp != 0 {
		idx -= 1
		buf[idx] = '0' + u8(tmp % 10)
		tmp /= 10
	}
	// Restore Negative Sign
	if n < 0 {
		idx -= 1
		buf[idx] = '-'
	}

	str := cstring(&buf[idx])
	return intern_string(str)
}
