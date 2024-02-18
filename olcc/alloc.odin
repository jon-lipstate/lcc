package lcc
import "core:mem"
import "core:os"

ptr_diff :: proc(a, b: rawptr) -> int {
	return int(transmute(uintptr)b - transmute(uintptr)a)
}
ptr_add :: proc(ptr: ^$T, incr: int) -> ^T {
	return transmute(^T)(transmute(uintptr)incr * size_of(T) + transmute(uintptr)ptr)
}
ptr_sub :: proc(ptr: ^$T, operand: ^T) -> ^T {
	return transmute(^T)(transmute(uintptr)ptr - transmute(uintptr)operand)
}

roundup :: proc(x, n: int) -> int {
	return (x + (n - 1)) & (~(n - 1))
}


Header :: struct {
	block: Block,
	align: u8,
}

Block :: struct {
	next:    ^Block,
	base:    [^]u8,
	n_bytes: int,
	used:    int,
}

ALIGN :: max(size_of(rawptr), size_of(int), size_of(f64), size_of(^u8))

PURIFY :: #config(purify, false)

when PURIFY {
	P_ARENA: [3]^Header
	allocate :: proc(n_bytes: uint, idx: Arena, zero_mem := false) -> [^]u8 {
		buf, err := mem.alloc(int(n_bytes) + size_of(Header))
		if err != mem.Allocator_Error.None {
			error("insufficent memory\n")
			os.exit(1)
		}
		hdr := transmute(^Header)buf
		// add to SLL:
		hdr.block.next = transmute(^Block)P_ARENA[int(idx)]
		P_ARENA[int(idx)] = hdr
		// setup arena-block:
		hdr.block.base = mem.ptr_offset(buf, size_of(Header))
		hdr.n_bytes = n_bytes

		return hdr.block.base
	}
	deallocate :: proc(idx: Arena) {
		p, q: ^Header
		for p = P_ARENA[int(idx)]; p != nil; p = q {
			q = transmute(^Header)p.block.next
			free(p)
		}
		P_ARENA[int(idx)] = nil
	}
	new_array :: proc(m, n: uint, a: uint) -> rawptr {
		return allocate(m * n, a)
	}
} else {
	first := [3]Block{}
	ARENA := [3]^Block{&first[0], &first[1], &first[2]}
	FREEBLOCKS: ^Block = nil

	allocate :: proc(n_bytes: uint, idx: Arena, zero_mem := false) -> [^]u8 {
		assert(n_bytes > 0)
		ap := transmute(^Block)ARENA[int(idx)]
		n_bytes := roundup(int(n_bytes), ALIGN)

		for n_bytes > ap.n_bytes - ap.used {
			ap.next = FREEBLOCKS
			if ap.next != nil {
				FREEBLOCKS = FREEBLOCKS.next
				ap = ap.next
			} else {
				m := size_of(Header) + n_bytes + roundup(10 * 1024, ALIGN)
				buf, err := mem.alloc(m, ALIGN)
				// set SLL:
				ap.next = transmute(^Block)buf
				ap = ap.next

				if ap == nil || err != mem.Allocator_Error.None {
					error("insufficient memory")
					os.exit(1)
				}
				// set arena:
				ap.base = mem.ptr_offset(transmute(^u8)buf, size_of(Header))
				ap.n_bytes = n_bytes
			}
			ap.next = nil
			ARENA[int(idx)] = ap
		}
		if zero_mem {mem.zero(ap.base, n_bytes)}
		return ap.base
	}
	deallocate :: proc(idx: Arena) {
		ARENA[int(idx)].next = FREEBLOCKS
		FREEBLOCKS = first[int(idx)].next // WHY FIRST????
		first[int(idx)].next = nil
		ARENA[int(idx)] = &first[int(idx)]
	}
	new_array :: proc(m, n: uint, idx: Arena) -> rawptr {
		return allocate(m * n, idx)
	}
}
