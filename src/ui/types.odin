#+feature dynamic-literals
package ui

import "core:dynlib"
import "core:mem"
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

ID :: distinct u64
ROOT_ID :: ID(0x726f6f74)

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

Text_Command :: struct {
	position:  vmath.vec2,
	color:     vmath.vec4,
	font_name: string,
	text:      string,
	size:      u16,
}

Render_Command :: union {
	Rect_Command,
	Text_Command,
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

Paint_Style :: struct {
	color: vmath.vec4,
}

Layout_Style :: struct {
	width:            Length,
	width_mode:       SizeMode,
	height:           Length,
	height_mode:      SizeMode,
	main_align:       MainAlign,
	cross_align:      CrossAlign,
	padding:          Edges,
	margin:           Edges,
	gap:              f32,
	layout_direction: Direction,
}

Style :: struct {
	using layout: Layout_Style,
	using paint:  Paint_Style,
}

Default_Style :: Style{}

Label_Element :: struct {
	font_name:    string,
	content: string,
	size:    f32,
	color:   vmath.vec4,
}

Label_Node :: struct {
	using label: Label_Element,
	lines:       [dynamic]string,
	position:    vmath.vec2,
}

// Input_Kind :: struct {
// 	content:     string,
// 	cursor:      i32,
// 	selectStart: i32, // -1 is none
// 	focused:     bool,
// }

Element_Kind :: union {
	Label_Element,
	// Input_Kind,
}

Node_Kind :: union {
	Label_Node,
	// Input_Kind,
}

Node :: struct {
	id:              ID,
	using style:     Style,
	kind:            Node_Kind,
	retained_width:  f32,
	retained_height: f32,
	position:        vmath.vec2,
	parent:          ^Node,
	children:        [dynamic]^Node,
	dirty:           bit_set[Dirty_Flag],
}

Element :: struct {
	style:     Style,
	kind:      Element_Kind,
	// on_click:  Callback,
	key:       u64,
	has_key:   bool,
	slot, sub: int, // identity info, filled in by kids()
	children:  [dynamic]Element,
}

Tree :: struct {
	root:         ^Node,
	allocator:    mem.Allocator,
	layout_roots: [dynamic]^Node,
}

Dirty_Flag :: enum {
	Layout_Root,
}
