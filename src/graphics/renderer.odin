package graphics

import "core:math/linalg"
import "simplex:assets"
import "simplex:vmath/"

BatchRenderer2D :: struct {
	batch_mesh: Instanced_Mesh,
	buffer:     [dynamic]Quad_Vertex_2D,
	shader:     Shader_Handle,
	texture:    Texture_Handle,
}

make_renderer_2D :: proc(shader: Shader_Handle, texture: Texture_Handle) -> BatchRenderer2D {
	return BatchRenderer2D {
		shader = shader,
		texture = texture,
		batch_mesh = create_instanced_quad_mesh(),
	}
}

destroy_renderer_2d :: proc(renderer: ^BatchRenderer2D) {
	destroy_instanced_mesh(&renderer.batch_mesh)
}

Rect_Command :: struct {
	transform: vmath.Transform,
	color:     vmath.vec4,
}

sumbit_command :: proc {
	submit_rect_command,
}

submit_rect_command :: proc(renderer: ^BatchRenderer2D, cmd: Rect_Command) {
	vertex := Quad_Vertex_2D {
		position         = cmd.transform.position.xy,
		size             = cmd.transform.size.xy,
		color            = cmd.color,
		texture_position = cmd.transform.position.xy,
		texture_size     = cmd.transform.size.xy,
	}
	append(&renderer.buffer, vertex)
}


render :: proc(
	renderer: ^BatchRenderer2D,
	asset_registry: ^assets.Asset_Registry,
	window_size: vmath.ivec2,
) {
	shader := assets.get_asset(asset_registry, Shader, renderer.shader)
	texture := assets.get_asset(asset_registry, Texture, renderer.texture)
	use_shader(shader^)

	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0

	projection := linalg.matrix_ortho3d(
		0,
		f32(window_size.x),
		0,
		f32(window_size.y),
		nearZClip,
		farZClip,
	)

	shader_set_mat4(shader^, "projection", &projection)

	bind_texture(texture)
	update_instance_data(&renderer.batch_mesh, renderer.buffer[:])
	draw_instanced(&renderer.batch_mesh, i32(len(&renderer.buffer)))

	clear(&renderer.buffer)
}
