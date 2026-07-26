package example_simplex

import "core:fmt"
import "simplex:assets"
import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:input"
import "simplex:view"
import "simplex:vmath"

render_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	mesh := ecs.get_component(&simplex.registry, entity, Renderable)
	graphics.submit_command(
		&simplex.renderer_2d,
		graphics.Rect_Command{transform = transform^, flip_tex = true},
	)
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

Renderable :: struct {
	texture: graphics.Texture_Handle,
	color:   vmath.vec4,
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
	font := graphics.load_font(&simplex.asset_registry, {path = "fonts/arial.ttf"})

	spriteShader := graphics.load_shader(
		&simplex.asset_registry,
		{vertexPath = "src/shaders/sprite.vert", fragmentPath = "src/shaders/sprite.frag"},
	)

	simplex.renderer_2d = graphics.make_renderer_2D(spriteShader)

	entity := ecs.create_entity(&simplex.registry)
	ecs.emplace_component(
		&simplex.registry,
		entity,
		vmath.Transform{position = {64, 64, 0}, size = {32, 32, 0}},
	)
	ecs.emplace_component(&simplex.registry, entity, Renderable{color = {1, 0, 0, 1}})

	camera_entity := ecs.create_entity(&simplex.registry)
	ecs.emplace_component(
		&simplex.registry,
		camera_entity,
		vmath.Transform{position = {0, 0, 0}, size = {0, 0, 0}},
	)
	ecs.emplace_component(
		&simplex.registry,
		camera_entity,
		Camera {
			zoom = 1,
			viewport_size = vmath.vec2({1920, 1080}),
			smoothing_speed = 10.0,
			deadzone = {{1, 1}, {1, 1}},
			target_position = {1, 1, 1},
		},
	)

	render_view := ecs.create_view(&simplex.registry, Renderable, vmath.Transform)
	font_ptr := assets.get_asset(&simplex.asset_registry, graphics.Font, font)

	for !core.should_quit(&simplex) {
		input.update(simplex.window.windowHandle)

		ecs.iterate_view(&render_view, &simplex, render_system)
		graphics.submit_command(
			&simplex.renderer_2d,
			graphics.Text_Command {
				position = {0, 0},
				font = font_ptr,
				text = "Hello World",
				color = {1, 1, 1, 1},
				size = 16,
			},
		)
		graphics.submit_command(
			&simplex.renderer_2d,
			graphics.Text_Command {
				position = {0, 100},
				font = font_ptr,
				text = "Hello World",
				color = {1, 1, 1, 1},
				size = 256,
			},
		)

		cam := ecs.get_component(&simplex.registry, camera_entity, Camera)
		cam_trans := ecs.get_component(&simplex.registry, camera_entity, vmath.Transform)

		cam.zoom = cam.zoom + (input.get_scroll_delta() * (0.5 * cam.zoom / 10.0))
		if (input.is_held(input.MouseButton.Mouse3)) {
			cam_delta := (input.get_mouse_delta() / cam.zoom)
			cam_trans.position = cam_trans.position + vmath.vec3{cam_delta.x, cam_delta.y, 0}
		}

		graphics.clear_color(simplex.options.backgroundColor)
		graphics.render(
			&simplex.renderer_2d,
			&simplex.asset_registry,
			vmath.ivec2(cam.viewport_size),
			cam.zoom,
			cam_trans.position.xy,
			font_ptr,
		)
		view.update(simplex.window)
	}

	core.shutdown(&simplex)
}
