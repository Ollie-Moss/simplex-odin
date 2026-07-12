package graphics

import "core:math/linalg"
import "simplex:assets"
import "simplex:vmath/"

Renderer3d :: struct {
	mesh:    Mesh,
	shader:  Shader_Handle,
	texture: Texture_Handle,
}

make_renderer_3d :: proc(shader: Shader_Handle, texture: Texture_Handle) -> Renderer3d {
	return Renderer3d{shader = shader, texture = texture, mesh = create_cube_mesh()}
}

destroy_renderer_3d :: proc(renderer: ^BatchRenderer2D) {
	destroy_instanced_mesh(&renderer.batch_mesh)
}


renderer3d_render :: proc(renderer: ^Renderer3d, asset_registry: ^assets.Asset_Registry) {
	shader := assets.get_asset(asset_registry, Shader, renderer.shader)
	texture := assets.get_asset(asset_registry, Texture, renderer.texture)
	use_shader(shader^)

	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0

	projection := linalg.matrix4_perspective(140, 100/100, f32(0.01), f32(100))
	translate := linalg.matrix4_translate(vmath.vec3{5, 5, -10})
	projection = projection * translate
	shader_set_mat4(shader^, "projection", &projection)

	//bind_texture(texture)
	draw(&renderer.mesh)
}
