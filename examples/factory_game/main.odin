package example_simplex

import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:input"
import "simplex:view"
import "simplex:vmath"

physics_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	transform.position.y -= 0.05
}

render_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	graphics.sumbit_command(&simplex.renderer_2d, {transform = transform^, color = {1, 0, 0, 1}})
}

cam_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
}

Camera :: struct {
	zoom:            f32,
	viewport_size:   vmath.vec2,
	smoothing_speed: f32,
	deadzone:        [2]vmath.vec2,
	target_position: vmath.vec3,
	position:        vmath.vec3,
}


PlayerController :: struct {
	move_speed: f32,
}


main :: proc() {

	simplex := core.make_simplex(
		{
			windowOptions = {windowSize = {1920, 1080}, title = "Simplex"},
			backgroundColor = {0.173, 0.169, 0.180, 1.00},
		},
	)
	core.init(&simplex)

	spriteShader := graphics.load_shader(
		&simplex.asset_registry,
		{vertexPath = "src/shaders/sprite.vert", fragmentPath = "src/shaders/sprite.frag"},
	)

	simplex.renderer_2d = graphics.make_renderer_2D(spriteShader)

	entity := ecs.create_entity(&simplex.registry)
	ecs.emplace_component(
		&simplex.registry,
		entity,
		vmath.Transform{position = {0, 0, 0}, size = {32, 32, 0}},
	)

	camera_entity := ecs.create_entity(&simplex.registry)
	ecs.emplace_component(
		&simplex.registry,
		camera_entity,
		vmath.Transform{position = {0, 0, 0}, size = {32, 32, 0}},
	)
	ecs.emplace_component(
		&simplex.registry,
		camera_entity,
		Camera {
			zoom = 100,
			viewport_size = vmath.vec2({1920, 1080}),
			smoothing_speed = 10.0,
			deadzone = {{1, 1}, {1, 1}},
			target_position = {1, 1, 1},
		},
	)

	//physics_view := ecs.create_view(&simplex.registry, vmath.Transform)
	render_view := ecs.create_view(&simplex.registry, vmath.Transform)

	for !core.should_quit(&simplex) {
		input.update()

		//ecs.iterate_view(&physics_view, &simplex, physics_system)
		ecs.iterate_view(&render_view, &simplex, render_system)

		cam := ecs.get_component(&simplex.registry, camera_entity, Camera)
		cam_trans := ecs.get_component(&simplex.registry, camera_entity, vmath.Transform)

		cam.zoom = cam.zoom + (input.get_scroll_delta() * (0.5 * cam.zoom / 10.0))

		graphics.clear_color(simplex.options.backgroundColor)
		graphics.render(
			&simplex.renderer_2d,
			&simplex.asset_registry,
			vmath.ivec2(cam.viewport_size),
			cam.zoom,
			vmath.ivec2(cam_trans.position.xy),
		)
		view.update(simplex.window)
	}

	core.shutdown(&simplex)
}
