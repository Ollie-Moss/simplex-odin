#+feature dynamic-literals
package ui

import "simplex:vmath"

render :: proc(root: ^Node) -> [dynamic]Rect_Command {
	commands := make([dynamic]Rect_Command, context.temp_allocator)
	breadth_first(root, render_node, &commands)
	return commands
}

render_node :: proc(node: ^Node, cmd_list: ^[dynamic]Rect_Command) {
	cmd := Rect_Command {
		size     = {node.retained_width, node.retained_height},
		position = node.position,
		color    = node.color,
	}

	append(cmd_list, cmd)
}
