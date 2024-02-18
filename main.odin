package occ
import "core:fmt"

main :: proc() {
	tok := init_tokenizer("./test.h")
	for !at_eof(&tok) {
		token := scan(&tok)
		fmt.println(token.kind, token.text)

		if token.kind == .Directive {
			buf: [16]Token
			dtoks := tokenize_directive(token, &buf)
			fmt.println("-------------- DIRECTIVE --------------")
			for tk in dtoks {
				fmt.println(tk.kind, tk.text)
			}
			fmt.println("-------------- END DIRECTIVE ----------")
		}
	}
}
