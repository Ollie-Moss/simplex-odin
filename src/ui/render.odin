#+feature dynamic-literals
package ui

import "simplex:vmath"

render :: proc(root: ^Node, buf: ^[dynamic]Render_Command) {
	breadth_first(root, render_node, buf)
}

render_node :: proc(node: ^Node, cmd_list: ^[dynamic]Render_Command) {
	cmd := Rect_Command {
		size     = {node.retained_width, node.retained_height},
		position = node.position,
		color    = node.color,
	}
	append(cmd_list, cmd)
	switch &kind in node.kind {
	case Label_Node:
		render_label_node(&kind, cmd_list)
	}
}

render_label_node :: proc(label: ^Label_Node, cmd_list: ^[dynamic]Render_Command) {
	position := label.position
	for line, i in label.lines {
		cmd := Text_Command {
			position  = position + {0, f32(i) * label.size},
			text      = line,
			color     = label.color,
			font_name = label.font_name,
			size      = u16(label.size),
		}
		append(cmd_list, cmd)
	}
}
