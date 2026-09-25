#+feature dynamic-literals
package ui

import "simplex:vmath"

// main :: proc() {
// 	retained_root := {}
// 	for true {
// 		tree := build(&some_state)
// 		retained_root := reconcile(&tree, retained_root)
// 		layout(&retained_root)
// 		cmds := render(&retained_root)
// 	}
// }

Edges :: struct {
	top:    f32,
	right:  f32,
	bottom: f32,
	left:   f32,
}

Direction :: enum {
	Horizontal,
	Vertical,
}

Rect_Command :: struct {
	transform: vmath.Transform,
	color:     vmath.vec4,
}

LengthType :: enum {
	Pixels,
	Percent,
}

Length :: struct {
	type: LengthType,
	size: f32,
}

pixels :: proc(amount: f32) -> Length {
	return {.Pixels, amount}
}

percent :: proc(amount: f32) -> Length {
	return {.Percent, amount}
}

SizeMode :: enum {
	Grow,
	Hug,
	Fixed,
}

Node :: struct {
	width:            Length,
	width_mode:       SizeMode,
	height:           Length,
	height_mode:      SizeMode,
	color:            vmath.vec4,
	padding:          Edges,
	margin:           Edges,
	gap:              f32,
	layout_direction: Direction,

	// RETAINED DATA
	dirty:            bool,
	retained_width:   f32,
	retained_height:  f32,
	children:         [dynamic]Node,
}

build :: proc(childrenCount: i32) -> Node {
	return Node {
		width = percent(50),
		height = pixels(20),
		color = {255, 0, 0, 1},
		children = [dynamic]Node {
			Node{width = percent(50), height = pixels(20), color = {255, 0, 0, 1}},
		},
	}
}

reconcile :: proc(tree: Node, retained_root: Node) -> Node {
	return tree
}

layout :: proc(tree: ^Node) {
	// Hug width
	reverse_breadth_first(tree, hug_width)

	// Grow width

	// Wrap text

	// Hug height

	// Grow height

	// Postitions
}

hug_width :: proc(node: ^Node) {
	if (node.width_mode != .Hug) {
		return
	}

	gap := f32(max(0, len(node.children) - 1)) * node.gap
	padding := node.padding.left + node.padding.right

	target_width := gap + padding

	if (node.layout_direction == .Horizontal) {
		target_width += sum_children_width(node)
	} else if (node.layout_direction == .Vertical) {
		target_width = get_largest_child_width(node)
	}

	node.retained_width = target_width
}

sum_children_width :: proc(node: ^Node) -> f32 {
	total: f32 = 0
	for child in node.children {
		total += child.retained_width
	}
	return total
}

// returns 0 if no children
get_largest_child_width :: proc(node: ^Node) -> f32 {
	largest: f32 = 0
	for child in node.children {
		if (child.retained_width > largest) {
			largest = child.retained_width
		}
	}
	return largest
}

render :: proc(tree: ^Node) -> [dynamic]Rect_Command {
	return nil
}


breadth_first :: proc(tree: ^Node, call_back: proc(node: ^Node)) {

}

reverse_breadth_first :: proc(node: ^Node, call_back: proc(node: ^Node)) {
	for &child in node.children {
		reverse_breadth_first(&child, call_back)
	}
	call_back(node)
}
