package example_simplex

import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:vmath"

render_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
	// transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	// renderable := ecs.get_component(&simplex.registry, entity, Renderable)
	// graphics.submit_command(
	// 	&simplex.renderer_2d,
	// 	graphics.Rect_Command {
	// 		texture = renderable.texture,
	// 		transform = transform^,
	// 		flip_tex = true,
	// 	},
	// )
}

Renderable :: struct {
	texture: graphics.Texture_Handle,
	color:   vmath.vec4,
}
