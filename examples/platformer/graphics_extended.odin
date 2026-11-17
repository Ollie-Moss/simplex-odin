package example_simplex

import "simplex:ecs"
import "simplex:graphics"
import "simplex:vmath"

render_system :: proc(
	renderer: ^graphics.BatchRenderer2D,
	entity: ecs.Entity,
	transform: ^vmath.Transform,
	renderable: ^Renderable,
) {
	cmd := graphics.Rect_Command {
		texture   = renderable.texture,
		transform = transform^,
		flip_tex  = true,
	}
	graphics.submit_command(renderer, &cmd)
}

Renderable :: struct {
	texture: graphics.Texture_Handle,
	color:   vmath.vec4,
}
