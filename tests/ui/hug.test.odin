#+feature dynamic-literals
package ui_test

import "core:testing"
import "simplex:ui"

@(test)
hug_width_no_children_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node{},
	}
	defer delete(root.children)

	ui.hug_pass(&root, .Width)
	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.retained_width, 0)
}

@(test)
hug_width_single_child_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node{ui.Node{retained_width = 250}},
	}
	defer delete(root.children)

	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.retained_width, 250)
}

@(test)
hug_width_many_children_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 100},
			ui.Node{retained_width = 200},
			ui.Node{retained_width = 300},
			ui.Node{retained_width = 400},
		},
	}
	defer delete(root.children)

	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.retained_width, 1000)
}

@(test)
hug_width_ignores_fixed_child_own_value_test :: proc(t: ^testing.T) {
	// A .Fixed child's own retained_width should still count toward its
	// hugging parent's total, even though the child itself isn't re-derived.
	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 150, width_mode = .Fixed},
			ui.Node{retained_width = 350, width_mode = .Fixed},
		},
	}
	defer delete(root.children)

	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.retained_width, 500)
}

@(test)
hug_width_nested_grandchildren_test :: proc(t: ^testing.T) {
	// grandchild widths should bubble up through an intermediate hugging
	// child and into the root, since reverse_breadth_first works bottom-up.
	inner := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 60},
			ui.Node{retained_width = 40},
		},
	}

	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node{inner, ui.Node{retained_width = 100}},
	}
	defer delete(root.children)
	defer delete(inner.children)

	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.children[0].retained_width, 100)
	testing.expect_value(t, root.retained_width, 200)
}

@(test)
hug_width_does_not_shrink_below_zero_test :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width = 0,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 0},
			ui.Node{retained_width = 0},
		},
	}
	defer delete(root.children)

	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.retained_width, 0)
}

@(test)
hug_width_preserves_existing_retained_width_when_recomputed_test :: proc(t: ^testing.T) {
	// Running hug_width on a node whose retained_width was already stale
	// (e.g. from a previous layout pass) should overwrite it with the fresh sum.
	root := ui.Node {
		retained_width = 9999,
		width_mode     = .Hug,
		children       = [dynamic]ui.Node {
			ui.Node{retained_width = 30},
			ui.Node{retained_width = 70},
		},
	}
	defer delete(root.children)

	ui.hug_pass(&root, .Width)

	testing.expect_value(t, root.retained_width, 100)
}
