package graphics

import "../assets"
import "../vmath/"
import "core:fmt"
import gl "vendor:OpenGL"

BatchRenderer2D :: struct {
	shader:     assets.Shader_Handle,
	batch_mesh: Instanced_Mesh,
	buffer:     [dynamic]Quad_Vertex_2D,
}

make_renderer_2D :: proc(shader: assets.Shader_Handle) -> BatchRenderer2D {
	return BatchRenderer2D{shader = shader, batch_mesh = create_instanced_quad_mesh()}
}

destroy_renderer_2d :: proc(renderer: ^BatchRenderer2D) {
	destroy_instanced_mesh(&renderer.batch_mesh)
}

Rect_Command :: struct {
	transform: vmath.Transform,
}

Render_Command :: union {
	Rect_Command,
}

clear_color :: proc(color: vmath.vec4) {
	gl.ClearColor(color.r, color.g, color.b, color.w)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

sumbit_command :: proc {
	submit_rect_command,
}

submit_rect_command :: proc(renderer: ^BatchRenderer2D, cmd: Rect_Command) {
	vertex := Quad_Vertex_2D {
		position         = cmd.transform.position.xy,
		size             = cmd.transform.size.xy,
		color            = vmath.vec4{0.0, 1.0, 1.0, 1.0},
		texture_position = cmd.transform.position.xy,
		texture_size     = cmd.transform.size.xy,
	}
	append(&renderer.buffer, vertex)
}


render :: proc(renderer: ^BatchRenderer2D, asset_registry: ^assets.Asset_Registry) {
	shader := assets.get_asset(asset_registry, assets.Shader, renderer.shader)
	//fmt.println(u32(shader^))
	use_shader(shader^)

	update_instance_data(&renderer.batch_mesh, renderer.buffer[:])
	draw_instanced(&renderer.batch_mesh, 1)
}
