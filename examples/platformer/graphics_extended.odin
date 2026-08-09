package example_simplex

import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:vmath"

render_system :: proc(
	simplex: ^core.Simplex,
	entity: ecs.Entity,
	transform: ^vmath.Transform,
	renderable: ^Renderable,
) {
	cmd := graphics.Rect_Command {
		texture   = renderable.texture,
		transform = transform^,
		flip_tex  = true,
	}
	graphics.submit_command(&simplex.renderer_2d, &cmd)
}

Renderable :: struct {
	texture: graphics.Texture_Handle,
	color:   vmath.vec4,
}
