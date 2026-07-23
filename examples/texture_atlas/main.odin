package example_simplex

import "core:fmt"
import "core:math/rand"
import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:input"
import "simplex:view"
import "simplex:vmath"

ColorComp :: struct {
	color: vmath.vec4,
}

physics_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	transform.position.y -= 0.05
}

render_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	color := ecs.get_component(&simplex.registry, entity, ColorComp)
	graphics.submit_command(&simplex.renderer_2d, {transform = transform^, color = color.color})
}


main :: proc() {

	simplex := core.make_simplex(
		{
			windowOptions = {windowSize = {1000, 1000}, title = "Simplex"},
			backgroundColor = {0.173, 0.169, 0.180, 1.00},
		},
	)
	core.init(&simplex)

	bin := vmath.Rect {
		size     = {500, 500},
		position = {0, 0},
	}

	rects_to_pack := []vmath.Rect {
		vmath.Rect{size = {300, 200}, position = {0, 0}},
		vmath.Rect{size = {200, 300}, position = {0, 0}},
		vmath.Rect{size = {150, 150}, position = {0, 0}},
		vmath.Rect{size = {200, 150}, position = {0, 0}},
		vmath.Rect{size = {100, 100}, position = {0, 0}},
		vmath.Rect{size = {100, 100}, position = {0, 0}},
		vmath.Rect{size = {75, 25}, position = {0, 0}},
		vmath.Rect{size = {75, 25}, position = {0, 0}},
		vmath.Rect{size = {25, 75}, position = {0, 0}},
		vmath.Rect{size = {25, 75}, position = {0, 0}},
		vmath.Rect{size = {60, 40}, position = {0, 0}},
		vmath.Rect{size = {20, 20}, position = {0, 0}},
		vmath.Rect{size = {20, 20}, position = {0, 0}},
		vmath.Rect{size = {15, 15}, position = {0, 0}},
	}

	packed, ok := vmath.bin_pack(bin, rects_to_pack)
	fmt.println(packed, ", ", ok)

	entity := ecs.create_entity(&simplex.registry)
	ecs.emplace_component(
		&simplex.registry,
		entity,
		vmath.Transform {
			position = {f32(bin.position.x), f32(bin.position.y), 0},
			size = {f32(bin.size.x), f32(bin.size.y), 0},
		},
	)
	ecs.emplace_component(
		&simplex.registry,
		entity,
		ColorComp{color = {rand.float32(), rand.float32(), rand.float32(), 1}},
	)
	for rect in packed {
		entity := ecs.create_entity(&simplex.registry)
		ecs.emplace_component(
			&simplex.registry,
			entity,
			vmath.Transform {
				position = {f32(rect.position.x), f32(rect.position.y), 0},
				size = {f32(rect.size.x), f32(rect.size.y), 0},
			},
		)
		ecs.emplace_component(
			&simplex.registry,
			entity,
			ColorComp{color = {rand.float32(), rand.float32(), rand.float32(), 1}},
		)
	}

	//physics_view := ecs.create_view(&simplex.registry, vmath.Transform)
	render_view := ecs.create_view(&simplex.registry, vmath.Transform)

	for !core.should_quit(&simplex) {
		input.update()

		//ecs.iterate_view(&physics_view, &simplex, physics_system)
		ecs.iterate_view(&render_view, &simplex, render_system)

		graphics.clear_color(simplex.options.backgroundColor)
		graphics.render(&simplex.renderer_2d, &simplex.asset_registry, view.view__window_size)
		view.update(simplex.window)
	}

	core.shutdown(&simplex)
}
