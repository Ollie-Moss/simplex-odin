package example_simplex

import "core:math/rand"
import "simplex:assets"
import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:vmath"

create_100k_entities :: proc(simplex: ^core.Simplex) {
	handle := graphics.load_texture(&simplex.asset_registry, {path = "images/Stone.png"})
	texture := assets.get_asset(&simplex.asset_registry, graphics.Texture, handle)
	rand.reset(123456)
	for i in 0 ..< 100_000 {
		tex_entity := ecs.create_entity(&simplex.registry)
		ecs.emplace_component(
			&simplex.registry,
			tex_entity,
			vmath.Transform {
				position = {rand.float32_range(0, 2560), rand.float32_range(0, 1440), 0},
				size = {f32(16), f32(16), 0},
			},
		)
		ecs.emplace_component(
			&simplex.registry,
			tex_entity,
			Renderable{texture = handle, color = {1, 0, 0, 1}},
		)

	}
}
