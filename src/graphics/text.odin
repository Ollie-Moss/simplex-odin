package graphics

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "simplex:assets"
import "simplex:graphics"
import "simplex:vmath"
import "vendor:stb/truetype"

Font_Handle :: assets.Asset_Handle

Font_Config :: struct {
	path: string,
}

Sized_Code_Point :: struct {
	size:       f32,
	code_point: rune,
}

Kern_Pair :: u16
Character_Id :: u32

Font :: struct {
	texture:          Texture_Handle,
	character_lookup: map[Character_Id]int,
	characters:       [dynamic]Character,
	ascent:           i32,
	descent:          i32,
	kern_lookup:      map[Kern_Pair]i32,
	line_gap:         i32,
	line_height:      f32,
	atlas_size:       f32,
}

Character :: struct {
	texture_offset: vmath.ivec2,
	texture_size:   vmath.ivec2,
	left_bearing:   i32,
	y_bearing:      i32,
	advance:        i32,
	glyph_index:    i32,
	scale:          f32,
}

// @(private)
// FONT_SIZES :: [12]f32{256, 128, 64, 48, 32, 24, 20, 18, 16, 14, 12, 10}
@(private)
FONT_SIZES :: [4]u16{256, 64, 32, 16}

@(private)
ENGLISH_CODE_POINTS :: [5][2]rune {
	{0x20, 0x7E}, // Basic Latin (ASCII)
	{0xA0, 0xFF}, // Latin-1 Supplement
	{0x2013, 0x2014}, // en/em dash
	{0x2018, 0x201D}, // curly quotes
	{0x2026, 0x2026}, // ellipsis
}

get_character_id :: proc(code_point: rune, size: u16) -> Character_Id {
	return u32(code_point) << 16 | u32(size)
}
get_kern_pair :: proc(glyph1: rune, glyph2: rune) -> Kern_Pair {
	return u16(u8(glyph1) << 8) | u16(glyph2)
}

get_character :: proc(
	font: ^Font,
	code_point: rune,
	target_size: u16,
) -> (
	char: Character,
	scale: f32,
) {
	best_distance := max(u32)
	size_to_use: u16 = 64
	for size in FONT_SIZES {
		distance := u32(size) - u32(target_size)
		if distance >= 0 && distance <= best_distance {
			best_distance = distance
			size_to_use = size
		}
	}
	filtered: [dynamic]u16
	filtered.allocator = context.temp_allocator
	reserve(&filtered, len(FONT_SIZES))

	// Manual filtering loop
	for size in FONT_SIZES {
		if size > size_to_use {
			append(&filtered, size)
		}
	}
	if len(filtered) > 0 {
		min, _ := slice.min_index(filtered[:])
		size_to_use = filtered[min]
	}


	i, exists := font.character_lookup[get_character_id(code_point, size_to_use)]
	if !exists {
		panic(
			fmt.tprint(
				"Could not find character for provided code_point and size: ",
				code_point,
				", ",
				size_to_use,
			),
		)
	}
	return font.characters[i], f32(target_size) / f32(size_to_use)}

load_font :: proc(registry: ^assets.Asset_Registry, config: Font_Config) -> Font_Handle {

	data, _ := os.read_entire_file(config.path, context.allocator)
	font_info: truetype.fontinfo

	if (!truetype.InitFont(&font_info, raw_data(data), 0)) {
		panic(fmt.tprintf("Ahhh font did not load: %s", config.path))
	}

	max_texture_size: i32 = 4096

	font := Font {
		atlas_size = f32(max_texture_size),
	}

	truetype.GetFontVMetrics(&font_info, &font.ascent, &font.descent, &font.line_gap)


	kern_table_len := truetype.GetKerningTableLength(&font_info)
	kern_table := make([dynamic]truetype.kerningentry, kern_table_len)
	defer delete(kern_table)

	truetype.GetKerningTable(&font_info, raw_data(kern_table), kern_table_len)

	for entry in kern_table {
		font.kern_lookup[get_kern_pair(entry.glyph1, entry.glyph2)] = entry.advance
	}

	for range in ENGLISH_CODE_POINTS {
		for code_point in range[0] ..= range[1] {
			char := Character{}
			glyph_index := truetype.FindGlyphIndex(&font_info, code_point)
			truetype.GetGlyphHMetrics(&font_info, glyph_index, &char.advance, &char.left_bearing)

			for size in FONT_SIZES {
				scale := truetype.ScaleForPixelHeight(&font_info, f32(size))

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
				char.y_bearing = -iy0
				char.scale = scale
				char.glyph_index = glyph_index

				append(&font.characters, char)

				font.character_lookup[get_character_id(code_point, size)] =
					len(font.characters) - 1
			}
		}
	}

	single_channel_image_buffer, _ := mem.alloc_bytes(int(max_texture_size * max_texture_size))
	defer delete(single_channel_image_buffer)

	free_rects := make([dynamic]vmath.Rect)
	reserve(&free_rects, len(font.characters) * 4)
	append(&free_rects, vmath.Rect{size = {max_texture_size, max_texture_size}})

	padding: i32 = 10

	for &char in font.characters {
		rect := vmath.Rect {
			size = char.texture_size + padding,
		}

		packed_rect, ok := vmath.pack_rect(&free_rects, rect)
		if !ok {
			panic(fmt.tprint("Failed to pack glyph: ", char.glyph_index))
		}
		char.texture_offset = packed_rect.position + padding
		buffer_offset := char.texture_offset.y * max_texture_size + char.texture_offset.x
		truetype.MakeGlyphBitmap(
			&font_info,
			raw_data(single_channel_image_buffer[buffer_offset:]),
			char.texture_size.x,
			char.texture_size.y,
			max_texture_size,
			char.scale,
			char.scale,
			char.glyph_index,
		)
	}

	four_channel_image_buffer, _ := mem.alloc_bytes(int(max_texture_size * max_texture_size) * 4)
	defer delete(four_channel_image_buffer)

	for i in 0 ..< len(single_channel_image_buffer) {
		j := i * 4

		for &subpixel in four_channel_image_buffer[j:][:3] {
			subpixel = 0xFF
		}
		four_channel_image_buffer[j + 3] =
			single_channel_image_buffer[i] if single_channel_image_buffer[i] > 0 else 0
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
		internal_format = .RGBA,
		image_format    = .RGBA,
		wrap_s          = .Repeat,
		wrap_t          = .Repeat,
		filter_min      = .Linear,
		filter_max      = .Linear,
	}

	generate_texture(&texture, raw_data(four_channel_image_buffer))

	font.texture = assets.insert_asset(registry, texture)
	return assets.insert_asset(registry, font)
}
