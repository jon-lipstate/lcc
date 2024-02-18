package lcc

import "core:fmt"
import "core:os"

WFLAG: int
ERR_COUNT: int
ERR_LIMIT: int = 20

error :: proc(msg: string, args: ..any) {
	ERR_COUNT += 1
	if ERR_COUNT >= ERR_LIMIT {
		ERR_COUNT -= 1
		fmt.eprintf("Too Many Errors..\n")
		os.exit(1)
	}
	if FIRST_FILE != FILE_PATH && FIRST_FILE != "" && FILE_PATH != "" {
		fmt.eprintf("%s: ", FIRST_FILE)
	}
	fmt.eprintf("%v: ", &SRC)
	fmt.eprintf(msg, args)
}
warning :: proc(msg: string, args: ..any) {
	if WFLAG == 0 {
		ERR_COUNT -= 1
		error("Warning: ")
		fmt.eprintf(msg, args)
	}
}
