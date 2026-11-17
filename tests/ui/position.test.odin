#+feature dynamic-literals
package ui_test

import "core:testing"
import "simplex:ui"
import "simplex:vmath"

@(test)
position_main_align_start :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width   = 400,
		main_align       = .Start,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node{ui.Node{retained_width = 50, position = {400, 0}}},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Width)

	testing.expect_value(t, root.children[0].position, vmath.vec2{0, 0})
}

@(test)
position_main_align_center :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width   = 400,
		main_align       = .Center,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node{ui.Node{retained_width = 50, position = {400, 0}}},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Width)

	testing.expect_value(t, root.children[0].position, vmath.vec2{175, 0})
}

@(test)
position_main_align_end :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width   = 400,
		main_align       = .End,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node{ui.Node{retained_width = 50, position = {400, 0}}},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Width)

	testing.expect_value(t, root.children[0].position, vmath.vec2{350, 0})
}

@(test)
position_main_align_space_between :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width   = 400,
		main_align       = .SpaceBetween,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node {
			ui.Node{retained_width = 50, position = {400, 0}},
			ui.Node{retained_width = 50, position = {400, 0}},
		},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Width)

	testing.expect_value(t, root.children[0].position, vmath.vec2{0, 0})
	testing.expect_value(t, root.children[1].position, vmath.vec2{350, 0})
}

@(test)
position_main_align_space_around :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width   = 400,
		main_align       = .SpaceAround,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node {
			ui.Node{retained_width = 50, position = {400, 0}},
			ui.Node{retained_width = 50, position = {400, 0}},
		},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Width)

	testing.expect_value(t, root.children[0].position, vmath.vec2{75, 0}) // [empty:0-75, box: 75-125, empty: 125-275, box: 275-325, empty: 325-400]
	testing.expect_value(t, root.children[1].position, vmath.vec2{275, 0})
}

@(test)
position_main_align_space_evenly :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_width   = 400,
		main_align       = .SpaceEvenly,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node {
			ui.Node{retained_width = 50, position = {400, 0}},
			ui.Node{retained_width = 50, position = {400, 0}},
		},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Width)

	testing.expect_value(t, root.children[0].position, vmath.vec2{100, 0}) // [empty:0-100, box: 100-150, empty: 150-250, box: 250-300, empty: 300-400]
	testing.expect_value(t, root.children[1].position, vmath.vec2{250, 0})
}

@(test)
position_cross_align_start :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_height   = 400,
		cross_align      = .Start,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node{ui.Node{retained_height = 50, position = {0, 400}}},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Height)

	testing.expect_value(t, root.children[0].position, vmath.vec2{0, 0})
}

@(test)
position_cross_align_center :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_height   = 400,
		cross_align      = .Center,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node{ui.Node{retained_height = 50, position = {0, 400}}},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Height)

	testing.expect_value(t, root.children[0].position, vmath.vec2{0, 175})
}

@(test)
position_cross_align_end :: proc(t: ^testing.T) {
	root := ui.Node {
		retained_height   = 400,
		cross_align      = .End,
		layout_direction = .Horizontal,
		children         = [dynamic]ui.Node{ui.Node{retained_height = 50, position = {0, 400}}},
	}
	defer delete(root.children)

	ui.position_pass(&root, .Height)

	testing.expect_value(t, root.children[0].position, vmath.vec2{0, 350})
}
