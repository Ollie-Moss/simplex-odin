package graphics

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:slice"
import "simplex:assets"
import "simplex:graphics"
import "simplex:vmath"
import gl "vendor:OpenGL"
import "vendor:stb/image"
import "vendor:stb/truetype"

Font_Handle :: assets.Asset_Handle

Font_Config :: struct {
	path: string,
}

Font :: struct {
	texture:                Texture_Handle,
	codepoint_to_character: map[rune]int,
	characters:             [dynamic]Character,
	ascent:                 i32,
	descent:                i32,
	line_gap:               i32,
	line_height:            f32,
}

Character :: struct {
	texture_offset: vmath.ivec2,
	texture_size:   vmath.ivec2,
	left_bearing:   i32,
	advance:        i32,
	glyph_index:    i32,
	scale:          f32,
}

@(private)
FONT_SIZES :: [10]f32{64, 48, 32, 24, 20, 18, 16, 14, 12, 10}

@(private)
ENGLISH_CODE_POINTS :: [5][2]rune {
	{0x20, 0x7E}, // Basic Latin (ASCII)
	{0xA0, 0xFF}, // Latin-1 Supplement
	{0x2013, 0x2014}, // en/em dash
	{0x2018, 0x201D}, // curly quotes
	{0x2026, 0x2026}, // ellipsis
}

load_font :: proc(registry: ^assets.Asset_Registry, config: Font_Config) -> Font_Handle {

	data, _ := os.read_entire_file(config.path, context.allocator)
	font_info: truetype.fontinfo

	if (!truetype.InitFont(&font_info, raw_data(data), 0)) {
		panic(fmt.tprintf("Ahhh font did not load: %s", config.path))
	}

	max_texture_size: i32 = 2048
	// gl.GetIntegerv(gl.MAX_TEXTURE_SIZE, &max_texture_size)
	// max_texture_size /= 10
	font := Font{}

	truetype.GetFontVMetrics(&font_info, &font.ascent, &font.descent, &font.line_gap)
	for range in ENGLISH_CODE_POINTS {
		for code_point in range[0] ..= range[1] {
			char := Character{}
			glyph_index := truetype.FindGlyphIndex(&font_info, code_point)
			truetype.GetGlyphHMetrics(&font_info, glyph_index, &char.advance, &char.left_bearing)

			for size in FONT_SIZES {
				scale := truetype.ScaleForPixelHeight(&font_info, size)

				ix0, ix1, iy0, iy1: i32
				truetype.GetGlyphBitmapBox(
					&font_info,
					glyph_index,
					scale,
					scale,
					&ix0,
					&iy0,
					&ix1,
					&iy1,
				)
				char.texture_size = {ix1 - ix0, iy1 - iy0}
				char.scale = scale
				char.glyph_index = glyph_index
				append(&font.characters, char)
				font.codepoint_to_character[code_point] = len(font.characters) - 1
			}
		}
	}

	tex_buffer, _ := mem.alloc_bytes(int(max_texture_size * max_texture_size))
	defer delete(tex_buffer)

	free_rects := make([dynamic]vmath.Rect)
	reserve(&free_rects, len(font.characters) * 4)
	append(&free_rects, vmath.Rect{size = {max_texture_size, max_texture_size}})

	for &char in font.characters {
		rect := vmath.Rect {
			size = {char.texture_size.x, char.texture_size.y},
		}

		packed_rect, ok := vmath.pack_rect(&free_rects, rect)
		if !ok {
			panic(fmt.tprint("Failed to pack glyph: ", char.glyph_index))
		}
		char.texture_offset = packed_rect.position
		buffer_offset := char.texture_offset.y * max_texture_size + char.texture_offset.x
		truetype.MakeGlyphBitmap(
			&font_info,
			raw_data(tex_buffer[buffer_offset:]),
			char.texture_size.x,
			char.texture_size.y,
			max_texture_size,
			char.scale,
			char.scale,
			char.glyph_index,
		)

	}

	// image.write_png(
	// 	"packed_font",
	// 	max_texture_size,
	// 	max_texture_size,
	// 	1,
	// 	raw_data(tex_buffer),
	// 	max_texture_size,
	// )

	texture := Texture {
		width           = max_texture_size,
		height          = max_texture_size,
		internal_format = .RED,
		image_format    = .RED,
		wrap_s          = .Repeat,
		wrap_t          = .Repeat,
		filter_min      = .Nearest_Mipmap_Linear,
		filter_max      = .Nearest,
	}

	generate_texture(&texture, raw_data(tex_buffer))

	font.texture = assets.insert_asset(registry, texture)
	return assets.insert_asset(registry, font)
}
