package ui_host

import "simplex:assets"
import "simplex:graphics"
import "simplex:ui"
import "simplex:vmath"

render_ui :: proc(
	renderer: ^graphics.BatchRenderer2D,
	font_provider: ^Font_Provider,
	cmd_buf: ^[dynamic]ui.Render_Command,
) {
	for &cmd in cmd_buf {
		switch &kind in cmd {
		case ui.Rect_Command:
			submit_ui_rect_command(renderer, &kind)
		case ui.Text_Command:
			font := resolve_font(font_provider, kind.font_name)
			submit_ui_text_command(renderer, font, &kind)
		}
	}
}

submit_ui_rect_command :: proc(renderer: ^graphics.BatchRenderer2D, cmd: ^ui.Rect_Command) {
	vertex := graphics.Quad_Vertex_2D {
		position         = {cmd.position.x, cmd.position.y, 0},
		size             = cmd.size,
		color            = cmd.color,
		texture_position = cmd.position,
		texture_size     = {1, 1},
		texture          = assets.NULL_ASSET,
	}

	append(&renderer.buffer, vertex)
}

submit_ui_text_command :: proc(
	renderer: ^graphics.BatchRenderer2D,
	font: ^graphics.Font,
	cmd: ^ui.Text_Command,
) {

	position := cmd.position.xy
	for code_point, i in cmd.text {

		char, scale := graphics.get_character(font, code_point, cmd.size)
		offset := (f32(cmd.size) - f32(char.texture_size.y)) * scale

		descent := f32(char.texture_size.y - char.y_bearing) * scale
		vertex := graphics.Quad_Vertex_2D {
			position         = {position.x, position.y + offset + descent, 0},
			size             = vmath.vec2(char.texture_size) * scale,
			color            = cmd.color,
			texture_position = vmath.vec2(char.texture_offset) / font.atlas_size,
			texture_size     = vmath.vec2(char.texture_size) / font.atlas_size,
			texture          = font.texture,
		}

		append(&renderer.buffer, vertex)

		advance := char.advance
		if i < len(cmd.text) - 1 {
			next_code_point := rune(cmd.text[i + 1])
			pair := graphics.get_kern_pair(code_point, next_code_point)
			if pair in font.kern_lookup {
				advance += font.kern_lookup[pair]
			}
		}

		position.x += f32(char.advance) * char.scale * scale
	}
}
