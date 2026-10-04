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

Axis :: enum {
	Width,
	Height,
}


Edges :: struct {
	top:    f32,
	right:  f32,
	bottom: f32,
	left:   f32,
}

Direction :: enum {
	Horizontal,
	Vertical,
	Horizontal_Reverse,
	Vertical_Reverse,
}

Rect_Command :: struct {
	position: vmath.vec2,
	size:     vmath.vec2,
	color:    vmath.vec4,
}

Unit :: enum {
	Pixels,
	Percent,
}

Length :: struct {
	unit: Unit,
	size: f32,
}

SizeMode :: enum {
	Grow,
	Hug,
	Fixed,
}

MainAlign :: enum {
	Start,
	Center,
	End,
	SpaceBetween,
	SpaceAround,
	SpaceEvenly,
}

CrossAlign :: enum {
	Start,
	Center,
	End,
}

Node_Desc :: struct {}

Node :: struct {
	width:            Length,
	width_mode:       SizeMode,
	height:           Length,
	height_mode:      SizeMode,
	main_align:       MainAlign,
	cross_align:      CrossAlign,
	color:            vmath.vec4,
	padding:          Edges,
	margin:           Edges,
	gap:              f32,
	layout_direction: Direction,

	// RETAINED DATA
	dirty:            bool,
	retained_width:   f32,
	retained_height:  f32,
	position:         vmath.vec2,
	children:         [dynamic]Node,
}
