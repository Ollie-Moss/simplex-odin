#+feature dynamic-literals
package ui

import "simplex:vmath"

layout :: proc(root: ^Node, surface_size: vmath.vec2) {
	// Hug width
	hug_pass(root, .Width)

	// Grow width
	grow_pass(root, surface_size, .Width)

	// Wrap text

	// Hug height
	hug_pass(root, .Height)

	// Grow height
	grow_pass(root, surface_size, .Height)

	// Postitions
	position_pass(root, .Width)
	position_pass(root, .Height)
}

get_size_mode :: proc(n: ^Node, a: Axis) -> SizeMode {
	return n.width_mode if a == .Width else n.height_mode
}

get_retained :: proc(n: ^Node, a: Axis) -> ^f32 {
	return &n.retained_width if a == .Width else &n.retained_height
}

get_len_for_axis_vec2 :: proc(n: vmath.vec2, a: Axis) -> f32 {
	return n.x if a == .Width else n.y
}

set_retained :: proc(n: ^Node, a: Axis, target_retained: f32) {
	retained: ^f32 = get_retained(n, a)
	retained^ = target_retained
}

get_position :: proc(n: ^Node, a: Axis) -> ^f32 {
	return &n.position.x if a == .Width else &n.position.y
}

set_position :: proc(n: ^Node, a: Axis, target_retained: f32) {
	retained: ^f32 = get_position(n, a)
	retained^ = target_retained
}

get_padding :: proc(n: ^Node, a: Axis) -> f32 {
	return n.padding.left + n.padding.right if a == .Width else n.padding.top + n.padding.bottom
}

get_content_start :: proc(n: ^Node, a: Axis) -> f32 {
	pos := get_position(n, a)^
	return pos + n.padding.left if a == .Width else pos + n.padding.top
}

get_available :: proc(n: ^Node, a: Axis) -> f32 {
	return get_retained(n, a)^ - get_padding(n, a)
}

is_main_axis :: proc(n: ^Node, a: Axis) -> bool {
	horizontal :=
		(n.layout_direction == .Horizontal || n.layout_direction == .Horizontal_Reverse) &&
		a == .Width
	vertical :=
		(n.layout_direction == .Vertical || n.layout_direction == .Vertical_Reverse) &&
		a == .Height
	return horizontal || vertical
}

hug_pass :: proc(node: ^Node, axis: Axis) {
	reverse_breadth_first(node, hug_axis, axis)
}

hug_axis :: proc(node: ^Node, axis: Axis) {
	if (node.width_mode != .Hug) {
		return
	}

	gap := f32(max(0, len(node.children) - 1)) * node.gap
	padding := get_padding(node, axis)

	target_retained := gap + padding

	if is_main_axis(node, axis) {
		target_retained += sum_children(node, axis)
	} else {
		target_retained = get_largest_child(node, axis)
	}

	set_retained(node, axis, target_retained)
}

grow_pass :: proc(node: ^Node, surface_size: vmath.vec2, axis: Axis) {
	if get_size_mode(node, axis) == .Grow {
		set_retained(node, axis, get_len_for_axis_vec2(surface_size, axis))
	}
	breadth_first(node, grow_axis, axis)
}

grow_axis :: proc(node: ^Node, axis: Axis) {
	growable_children := make([dynamic]^Node, context.temp_allocator)
	for child in node.children {
		if get_size_mode(child, axis) == .Grow {
			append(&growable_children, child)
		}
	}

	if len(growable_children) == 0 {
		return
	}

	available_length: f32 = get_retained(node, axis)^ - get_padding(node, axis)

	if !is_main_axis(node, axis) {
		for child in growable_children {
			set_retained(child, axis, available_length)
		}
		return
	}

	available_length -= max(0, f32(len(node.children)) - 1) * node.gap

	for child in node.children {
		if get_size_mode(child, axis) == .Hug || get_size_mode(child, axis) == .Fixed {
			available_length -= get_retained(child, axis)^
		}
	}

	if available_length <= 0 {
		return
	}

	per_child_len := available_length / f32(len(growable_children))
	for child in growable_children {
		target_retained: f32 = get_retained(child, axis)^ + per_child_len
		set_retained(child, axis, target_retained)
	}
}

position_pass :: proc(node: ^Node, axis: Axis) {
	breadth_first(node, position_axis, axis)
}

position_axis :: proc(node: ^Node, axis: Axis) {
	if is_main_axis(node, axis) {
		position_main_align(node, axis)
	} else {
		position_cross_align(node, axis)
	}
}

position_main_align :: proc(node: ^Node, axis: Axis) {
	switch node.main_align {
	case .Start:
		pos := get_content_start(node, axis)
		for child in node.children {
			set_position(child, axis, pos)
			pos += get_retained(child, axis)^
			pos += node.gap
		}
	case .Center:
		available_length: f32 = get_available(node, axis) - sum_children(node, axis)
		available_length -= max(0, f32(len(node.children)) - 1) * node.gap

		pos := get_content_start(node, axis) + available_length / 2
		for child in node.children {
			set_position(child, axis, pos)
			pos += get_retained(child, axis)^
			pos += node.gap
		}
	case .End:
		available_length: f32 = get_available(node, axis) - sum_children(node, axis)
		available_length -= max(0, f32(len(node.children)) - 1) * node.gap

		pos := get_content_start(node, axis) + available_length
		for child in node.children {
			set_position(child, axis, pos)
			pos += get_retained(child, axis)^
			pos += node.gap
		}
	case .SpaceBetween:
		available_length: f32 = get_available(node, axis) - sum_children(node, axis)

		between_gap := available_length / f32(len(node.children))

		pos := get_content_start(node, axis)
		last_index := len(node.children) - 1

		for child, i in node.children {
			// last child needs the gap placed before it
			if i == last_index {
				pos += between_gap
			}
			set_position(child, axis, pos)

			pos += between_gap
			pos += get_retained(child, axis)^
		}
	case .SpaceEvenly:
		available_length: f32 = get_available(node, axis) - sum_children(node, axis)

		even_gap := available_length / (max(0, f32(len(node.children)) - 1) + 2) // number of "gaps" + 2 for the start and end

		pos := get_content_start(node, axis) + even_gap
		for child in node.children {
			set_position(child, axis, pos)

			pos += even_gap
			pos += get_retained(child, axis)^
		}
	case .SpaceAround:
		available_length: f32 = get_retained(node, axis)^ - get_padding(node, axis)

		for child in node.children {
			available_length -= get_retained(child, axis)^
		}

		even_gap := available_length / (f32(len(node.children)) + 2)

		pos := get_content_start(node, axis)
		for child in node.children {
			pos += even_gap
			set_position(child, axis, pos)

			pos += even_gap
			pos += get_retained(child, axis)^
		}
	}
}

position_cross_align :: proc(node: ^Node, axis: Axis) {
	// pos + some_offset
	pos := get_content_start(node, axis)
	available := get_available(node, axis)

	for child in node.children {
		offset: f32 = 0
		#partial switch node.cross_align {
		case .Start:
		case .Center:
			offset = (available - get_retained(child, axis)^) / 2
		case .End:
			offset = available - get_retained(child, axis)^
		}
		set_position(child, axis, pos + offset)
	}
}

sum_children :: proc(node: ^Node, axis: Axis) -> f32 {
	total: f32 = 0
	for child in node.children {
		total += get_retained(child, axis)^
	}
	return total
}

// returns 0 if no children
get_largest_child :: proc(node: ^Node, axis: Axis) -> f32 {
	largest: f32 = 0
	for child in node.children {
		retained := get_retained(child, axis)^
		if (retained > largest) {
			largest = retained
		}
	}
	return largest
}

breadth_first :: proc {
	breadth_first_no_args,
	breadth_first_one_arg,
	breadth_first_one_arg_passed,
}

breadth_first_no_args :: proc(node: ^Node, call_back: proc(node: ^Node)) {
	call_back(node)
	for child in node.children {
		breadth_first_no_args(child, call_back)
	}
}

breadth_first_one_arg :: proc(node: ^Node, call_back: proc(node: ^Node, a: $A), a: A) {
	call_back(node, a)
	for child in node.children {
		breadth_first_one_arg(child, call_back, a)
	}
}

breadth_first_one_arg_passed :: proc(node: ^Node, call_back: proc(node: ^Node, a: $A) -> A, a: A) {
	result := call_back(node, a)
	for child in node.children {
		breadth_first_one_arg(child, call_back, result)
	}
}

reverse_breadth_first :: proc {
	reverse_breadth_first_no_args,
	reverse_breadth_first_one_arg,
}

reverse_breadth_first_no_args :: proc(node: ^Node, call_back: proc(node: ^Node)) {
	for child in node.children {
		reverse_breadth_first_no_args(child, call_back)
	}
	call_back(node)
}

reverse_breadth_first_one_arg :: proc(node: ^Node, call_back: proc(node: ^Node, a: $A), a: A) {
	for child in node.children {
		reverse_breadth_first_one_arg(child, call_back, a)
	}
	call_back(node, a)
}
