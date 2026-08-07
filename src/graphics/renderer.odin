package graphics

import "simplex:assets"
import "simplex:graphics"
import "simplex:vmath/"

BatchRenderer2D :: struct {
	batch_mesh: Instanced_Mesh,
	buffer:     [dynamic]Quad_Vertex_2D,
	shader:     Shader_Handle,
}

Batch :: struct {
	texture: Texture_Handle,
	start:   int,
	end:     int,
}

make_renderer_2D :: proc(shader: Shader_Handle) -> BatchRenderer2D {
	return BatchRenderer2D {
		shader = shader,
		batch_mesh = create_instanced_quad_mesh(),
		buffer = make([dynamic]Quad_Vertex_2D, 100_000),
	}
}

destroy_renderer_2d :: proc(renderer: ^BatchRenderer2D) {
	destroy_instanced_mesh(&renderer.batch_mesh)
	delete(renderer.buffer)
}

Rect_Command :: struct {
	transform: vmath.Transform,
	color:     vmath.vec4,
	flip_tex:  bool,
	texture:   Texture_Handle,
}

Text_Command :: struct {
	position: vmath.vec2,
	color:    vmath.vec4,
	font:     ^Font,
	text:     string,
	size:     u16,
}

submit_command :: proc {
	submit_rect_command,
	submit_text_command,
}

submit_text_command :: proc(renderer: ^BatchRenderer2D, cmd: Text_Command) {
	position := cmd.position.xy
	for code_point, i in cmd.text {
		char, scale := get_character(cmd.font, code_point, cmd.size)

		descent := f32(char.texture_size.y - char.y_bearing) * scale
		vertex := Quad_Vertex_2D {
			position         = {position.x, position.y - descent, 0},
			size             = vmath.vec2(char.texture_size) * scale,
			color            = cmd.color,
			texture_position = vmath.vec2(char.texture_offset) / cmd.font.atlas_size,
			texture_size     = vmath.vec2(char.texture_size) / cmd.font.atlas_size,
			texture          = cmd.font.texture,
		}

		// flip y
		// vertex.texture_position.y += vertex.texture_size.y
		// vertex.texture_size.y *= -1

		append(&renderer.buffer, vertex)

		advance := char.advance
		if i < len(cmd.text) - 1 {
			next_code_point := rune(cmd.text[i + 1])
			pair := get_kern_pair(code_point, next_code_point)
			if pair in cmd.font.kern_lookup {
				advance += cmd.font.kern_lookup[pair]
			}
		}

		position.x += f32(char.advance) * char.scale * scale
	}
}

submit_rect_command :: proc(renderer: ^BatchRenderer2D, cmd: Rect_Command) {
	vertex := Quad_Vertex_2D {
		position         = cmd.transform.position.xyz,
		size             = cmd.transform.size.xy,
		color            = cmd.color,
		texture_position = cmd.transform.position.xy,
		texture_size     = {1, 1},
	}

	if cmd.flip_tex {
		vertex.texture_size = {1, -1}
	}

	if cmd.texture != assets.NULL_ASSET {
		vertex.texture = cmd.texture
	}
	append(&renderer.buffer, vertex)
}

render :: proc(
	renderer: ^BatchRenderer2D,
	asset_registry: ^assets.Asset_Registry,
	projection: matrix[4, 4]f32,
) {
	shader := assets.get_asset(asset_registry, Shader, renderer.shader)
	use_shader(shader^)

	proj := projection
	shader_set_mat4(shader^, "projection", &proj)

	buffer := renderer.buffer[:]
	if len(buffer) < 1 {
		return
	}

	// slice.sort_by_cmp(
	// 	buffer,
	// 	proc(a, b: Quad_Vertex_2D) -> slice.Ordering {return (slice.Ordering(
	// 					cast(i32)math.sign(a.position.z - b.position.z),
	// 				))},
	// )

	prev_texture := buffer[0].texture
	batch_start := 0

	for vertex, i in buffer[:] {
		if vertex.texture != prev_texture {
			batch := Batch {
				texture = prev_texture,
				start   = batch_start,
				end     = i,
			}
			draw_batch(renderer, asset_registry, batch)
			prev_texture = vertex.texture
			batch_start = i
		}
	}
	batch := Batch {
		texture = prev_texture,
		start   = batch_start,
		end     = len(buffer),
	}

	draw_batch(renderer, asset_registry, batch)
	clear(&renderer.buffer)
}

draw_batch :: proc(
	renderer: ^BatchRenderer2D,
	asset_registry: ^assets.Asset_Registry,
	batch: Batch,
) {
	update_instance_data(&renderer.batch_mesh, renderer.buffer[batch.start:batch.end])
	if batch.texture != assets.NULL_ASSET {
		texture := assets.get_asset(asset_registry, Texture, batch.texture)
		bind_texture(texture)
	}
	draw_instanced(&renderer.batch_mesh)
	clear_texture()
}
