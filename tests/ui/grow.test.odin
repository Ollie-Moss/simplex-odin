#+feature dynamic-literals
package ui_test

import "core:testing"
import "simplex:ui"
import "simplex:vmath"


@(test)
grow_width_no_children_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 500,
		width_mode     = .Grow,
		children       = [dynamic]ui.Node{},
	}
	defer delete(root.children)

	surface_size := vmath.vec2{100, 100}

	ui.grow_pass(&root, surface_size, .Width)

	testing.expect_value(t, root.retained_width, surface_size.x)
}

@(test)
grow_width_single_child_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 500,
		width_mode     = .Fixed,
		children       = [dynamic]ui.Node{ui.Node{retained_width = 0, width_mode = .Grow}},
	}
	defer delete(root.children)

	surface_size := vmath.vec2{100, 100}

	ui.grow_pass(&root, surface_size, .Width)

	testing.expect_value(t, root.children[0].retained_width, 500)
}

@(test)
grow_width_many_children_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 400,
		width_mode     = .Fixed,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 0, width_mode = .Grow},
			ui.Node{retained_width = 0, width_mode = .Grow},
			ui.Node{retained_width = 0, width_mode = .Grow},
			ui.Node{retained_width = 0, width_mode = .Grow},
		},
	}
	defer delete(root.children)

	surface_size := vmath.vec2{100, 100}

	ui.grow_pass(&root, surface_size, .Width)

	testing.expect_value(t, root.children[0].retained_width, 100)
	testing.expect_value(t, root.children[1].retained_width, 100)
	testing.expect_value(t, root.children[2].retained_width, 100)
	testing.expect_value(t, root.children[3].retained_width, 100)
}

@(test)
grow_width_ignores_fixed_sibling_space_test :: proc(t: ^testing.T) {
	// Grow child should only claim leftover space after fixed siblings
	// have taken their share.
	root := ui.Node {
		retained_width   = 500,
		width_mode       = .Fixed,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node {
			ui.Node{retained_width = 150, width_mode = .Fixed},
			ui.Node{retained_width = 0, width_mode = .Grow},
		},
	}
	defer delete(root.children)

	surface_size := vmath.vec2{100, 100}

	ui.grow_pass(&root, surface_size, .Width)

	testing.expect_value(t, root.children[0].retained_width, 150)
	testing.expect_value(t, root.children[1].retained_width, 350)
}

@(test)
grow_width_nested_grandchildren_test :: proc(t: ^testing.T) {
	// A Grow child that resolves its own width first should then push
	// that resolved width down into its own Grow grandchildren.
	inner := ui.Node {
		retained_width = 0,
		width_mode     = .Grow,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 0, width_mode = .Grow},
			ui.Node{retained_width = 0, width_mode = .Grow},
		},
	}

	root := ui.Node {
		retained_width = 300,
		width_mode     = .Fixed,
		children       = [dynamic]ui.Node {
			inner,
			ui.Node{retained_width = 100, width_mode = .Fixed},
		},
	}
	defer delete(root.children)
	defer delete(inner.children)

	surface_size := vmath.vec2{100, 100}

	ui.grow_pass(&root, surface_size, .Width)

	testing.expect_value(t, root.children[0].retained_width, 200)
	testing.expect_value(t, root.children[0].children[0].retained_width, 100)
	testing.expect_value(t, root.children[0].children[1].retained_width, 100)
}

@(test)
grow_width_does_not_shrink_below_zero_test :: proc(t: ^testing.T) {
	// Fixed siblings already exceed the parent's width; the Grow child
	// should clamp to 0 rather than go negative.
	root := ui.Node {
		retained_width = 100,
		width_mode     = .Fixed,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 80, width_mode = .Fixed},
			ui.Node{retained_width = 80, width_mode = .Fixed},
			ui.Node{retained_width = 0, width_mode = .Grow},
		},
	}
	defer delete(root.children)

	surface_size := vmath.vec2{100, 100}

	ui.grow_pass(&root, surface_size, .Width)

	testing.expect_value(t, root.children[2].retained_width, 0)
}
