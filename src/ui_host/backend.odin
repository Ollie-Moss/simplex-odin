package ui_host

import "simplex:graphics"
import "simplex:ui"
import "simplex:vmath"

make_backend :: proc(
	font_provider: ^Font_Provider,
	allocator := context.allocator,
) -> ^ui.Text_Backend {
	return ui.make_text_backend(font_provider, measure_text, allocator)
}

measure_text :: proc(
	backend: ^ui.Text_Backend,
	text: string,
	opts: ui.Text_Measure_Options,
) -> f32 {
	font_provider := cast(^Font_Provider)backend.data
	font := resolve_font(font_provider, opts.font_name)
	total_width: f32 = 0

	position := vmath.vec2{0, 0}
	for code_point, i in text {

		char, scale := graphics.get_character(font, code_point, u16(opts.font_size))
		offset := (opts.font_size - f32(char.texture_size.y)) * scale

		descent := f32(char.texture_size.y - char.y_bearing) * scale
		glyph_width := f32(char.texture_size.x) * scale
		max_right := position.x + glyph_width

		if max_right > total_width {
			total_width = max_right
		}

		advance := char.advance
		if i < len(text) - 1 {
			next_code_point := rune(text[i + 1])
			pair := graphics.get_kern_pair(code_point, next_code_point)
			if pair in font.kern_lookup {
				advance += font.kern_lookup[pair]
			}
		}

		position.x += f32(char.advance) * char.scale * scale
	}
	return total_width
}
