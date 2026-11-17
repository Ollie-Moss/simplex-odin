
#+feature dynamic-literals
package ui_test

import "core:testing"
import "simplex:ui"


@(test)
render_should_return_valid_commands :: proc(t: ^testing.T) {
	root := ui.Node {
		width_mode = .Grow,
		color      = {255, 0, 0, 255},
		children   = [dynamic]ui.Node {
			ui.Node{width_mode = .Grow, color = {0, 0, 0, 255}},
			ui.Node{width_mode = .Grow, color = {0, 255, 0, 255}},
			ui.Node{width_mode = .Grow, color = {0, 0, 255, 255}},
		},
	}
}
