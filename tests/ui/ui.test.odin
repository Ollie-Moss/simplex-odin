#+feature dynamic-literals
package ui_test

import "core:testing"
import "simplex:ui"

// TESTS
@(test)
hug_width_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 500},
			ui.Node{retained_width = 500},
		},
	}
	defer delete(root.children)

	ui.reverse_breadth_first(&root, ui.hug_width)

	testing.expect_value(t, root.retained_width, 1000)
}
