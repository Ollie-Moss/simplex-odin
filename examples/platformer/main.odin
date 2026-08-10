package example_simplex

import "core:fmt"
import "core:os"
import "core:strings"
import "simplex:assets"
import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:input"
import "simplex:view"
import "simplex:vmath"

PlayerController :: struct {
	move_speed: f32,
}

main :: proc() {
	opts := core.Simplex_Options {
		windowOptions = {windowSize = {1920, 1080}, title = "Simplex"},
		backgroundColor = {0.173, 0.169, 0.180, 1.00},
	}

	simplex := core.make_simplex(opts)
	core.init(&simplex)

	font := graphics.load_font(&simplex.asset_registry, {path = "fonts/arial.ttf"})

	spriteShader := graphics.load_shader(
		&simplex.asset_registry,
		{vertexPath = "src/shaders/sprite.vert", fragmentPath = "src/shaders/sprite.frag"},
	)

	renderer := graphics.make_renderer_2D(spriteShader)

	entity := ecs.create_entity(&simplex.registry)
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
			viewport_size = vmath.ivec2(opts.windowOptions.windowSize),
			smoothing_speed = 10.0,
			deadzone = {{1, 1}, {1, 1}},
		},
	)

	render_view := ecs.create_view(&simplex.registry, vmath.Transform, Renderable)
	font_ptr := assets.get_asset(&simplex.asset_registry, graphics.Font, font)
	stats := make_engine_stats()

	files, err := os.read_all_directory_by_path("images", context.allocator)
	if err != .NONE {
		panic("aahhhh no images")
	}

	// for file in files {
	// 	// skip nested dirs for now
	// 	if file.type == .Directory {
	// 		continue
	// 	}
	// 	handle := graphics.load_texture(&simplex.asset_registry, {path = file.fullpath})
	// 	texture := assets.get_asset(&simplex.asset_registry, graphics.Texture, handle)
	// 	fmt.println(texture.handle)
	// 	tex_entity := ecs.create_entity(&simplex.registry)
	// 	ecs.emplace_component(
	// 		&simplex.registry,
	// 		tex_entity,
	// 		vmath.Transform {
	// 			position = {500, 500, 0},
	// 			size = {f32(texture.width), f32(texture.height), 0},
	// 		},
	// 	)
	// 	ecs.emplace_component(
	// 		&simplex.registry,
	// 		tex_entity,
	// 		Renderable{texture = handle, color = {1, 0, 0, 1}},
	// 	)
	// }

	ui_renderer := graphics.make_renderer_2D(spriteShader)

	for !core.should_quit(&simplex) {
		calculate_fps(&stats, 0.04)

		input.update(simplex.window.windowHandle)

		ecs.iterate_view(&render_view, &renderer, render_system)

		fps_str := fmt.tprintf("%.0f", stats.fps)
		fps_display := fmt.tprintf("FPS: |%s|", strings.center_justify(fps_str, 20, " "))

		graphics.submit_command(
			&ui_renderer,
			graphics.Text_Command {
				position = {0, 0},
				font = font_ptr,
				text = fps_display,
				color = {1, 1, 1, 1},
				size = 16,
			},
		)
		// graphics.submit_command(
		// 	&renderer2d,
		// 	graphics.Text_Command {
		// 		position = {0, 100},
		// 		font = font_ptr,
		// 		text = "Hello World",
		// 		color = {1, 1, 1, 1},
		// 		size = 256,
		// 	},
		// )

		cam := ecs.get_component(&simplex.registry, camera_entity, Camera)
		cam_trans := ecs.get_component(&simplex.registry, camera_entity, vmath.Transform)
		cam.viewport_size = view.get_window_size(&simplex.window)

		cam.zoom = cam.zoom + (input.get_scroll_delta() * (0.5 * cam.zoom / 10.0))
		if (input.is_held(input.MouseButton.Mouse3)) {
			cam_delta := (input.get_mouse_delta() / cam.zoom)
			cam_delta.y *= -1

			cam_trans.position = cam_trans.position + vmath.vec3{cam_delta.x, cam_delta.y, 0}
		}

		graphics.clear_color(simplex.options.backgroundColor)
		graphics.render(
			&renderer,
			&simplex.asset_registry,
			calculate_camera_projection(cam_trans, cam),
		)
		graphics.render(
			&ui_renderer,
			&simplex.asset_registry,
			calculate_projection(vmath.vec2(view.get_window_size(&simplex.window))),
		)
		view.update(simplex.window)

		free_all(context.temp_allocator)
	}

	core.shutdown(&simplex)
}
