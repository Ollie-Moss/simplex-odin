package graphics

import "core:math/linalg"
import "simplex:assets"
import "simplex:vmath/"

BatchRenderer2D :: struct {
	batch_mesh: Instanced_Mesh,
	buffer:     [dynamic]Quad_Vertex_2D,
	shader:     Shader_Handle,
}

make_renderer_2D :: proc(shader: Shader_Handle) -> BatchRenderer2D {
	return BatchRenderer2D{shader = shader, batch_mesh = create_instanced_quad_mesh()}
}

destroy_renderer_2d :: proc(renderer: ^BatchRenderer2D) {
	destroy_instanced_mesh(&renderer.batch_mesh)
}

Rect_Command :: struct {
	transform: vmath.Transform,
	color:     vmath.vec4,
	flip_tex:  bool,
}

submit_command :: proc {
	submit_rect_command,
}

submit_rect_command :: proc(renderer: ^BatchRenderer2D, cmd: Rect_Command) {
	vertex := Quad_Vertex_2D {
		position         = cmd.transform.position.xy,
		size             = cmd.transform.size.xy,
		color            = cmd.color,
		texture_position = cmd.transform.position.xy,
		texture_size     = {1, 1},
	}

	if cmd.flip_tex {
		vertex.texture_size = {1, -1}
	}
	append(&renderer.buffer, vertex)
}

render :: proc(
	renderer: ^BatchRenderer2D,
	asset_registry: ^assets.Asset_Registry,
	viewport_size: vmath.ivec2,
	zoom: f32,
	cam_position: vmath.vec2,
	font: ^Font,
) {
	shader := assets.get_asset(asset_registry, Shader, renderer.shader)
	use_shader(shader^)

	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0

	halfWidth := f32(viewport_size.x) / zoom / 2.0
	halfHeight := f32(viewport_size.y) / zoom / 2.0
	projection := linalg.matrix_ortho3d(
		f32(cam_position.x) - halfWidth,
		f32(cam_position.x) + halfWidth,
		f32(cam_position.y) - halfHeight,
		f32(cam_position.y) + halfHeight,
		nearZClip,
		farZClip,
	)

	shader_set_mat4(shader^, "projection", &projection)

	update_instance_data(&renderer.batch_mesh, renderer.buffer[:])
	bind_texture(assets.get_asset(asset_registry, Texture, font.texture))
	draw_instanced(&renderer.batch_mesh)

	clear(&renderer.buffer)
}
