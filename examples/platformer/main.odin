#+feature dynamic-literals
package example_simplex

import "core:fmt"
import "core:os"
import "core:strings"
import "simplex:assets"
import "simplex:core"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:input"
import "simplex:ui"
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
	tree := ui.make_tree()
	defer ui.delete_tree(tree)

	for !core.should_quit(&simplex) {
		calculate_fps(&stats, 0.04)

		input.update(simplex.window.windowHandle)

		ecs.iterate_view(&render_view, &renderer, render_system)

		fps_str := fmt.tprintf("%.0f", stats.fps)
		fps_display := fmt.tprintf(
			"FPS: |%s|",
			strings.center_justify(fps_str, 20, " ", context.temp_allocator),
		)

		ui_view := ui.column(
			ui.Style {
				width_mode = .Grow,
				height_mode = .Grow,
				color = ui.hex(0x121211),
				padding = {10, 10, 10, 10},
				gap = 12,
			},
			ui.row(
				ui.Style{width_mode = .Grow, height_mode = .Grow, color = ui.hex(0x262624)}, // header
				ui.label(fps_display, {width_mode = .Grow, color = {0, 0, 0, 0}}),
			),
			ui.element(
				ui.Style{width_mode = .Grow, color = ui.hex(0x262624)}, // content
				ui.show(input.is_held_mouse(.Mouse1), ui.label("Mouse Held")),
			),
		)

		surface_size := vmath.vec2(view.get_window_size(&simplex.window))

		ui.reconcile(tree, ui_view)
		ui.layout(tree, surface_size)
		cmds := make([dynamic]ui.Render_Command, context.temp_allocator)
		ui.render(tree.root, &cmds)

		defer delete(cmds)
		for &cmd in cmds {
			switch &kind in cmd {
			case ui.Rect_Command:
				submit_ui_rect_command(&ui_renderer, &kind)
			case ui.Text_Command:
				submit_ui_text_command(&ui_renderer, &kind, font_ptr)
			}
		}

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

submit_ui_rect_command :: proc(renderer: ^graphics.BatchRenderer2D, cmd: ^ui.Rect_Command) {
	vertex := graphics.Quad_Vertex_2D {
		position         = {cmd.position.x, cmd.position.y, 0},
		size             = cmd.size,
		color            = cmd.color,
		texture_position = cmd.position,
		texture_size     = {1, 1},
		texture          = assets.NULL_ASSET,
	}

	append(&renderer.buffer, vertex)
}

submit_ui_text_command :: proc(
	renderer: ^graphics.BatchRenderer2D,
	cmd: ^ui.Text_Command,
	font: ^graphics.Font,
) {
	position := cmd.position.xy
	for code_point, i in cmd.text {
		char, scale := graphics.get_character(font, code_point, cmd.size)
		offset := (f32(cmd.size) - f32(char.texture_size.y)) * scale

		descent := f32(char.texture_size.y - char.y_bearing) * scale
		vertex := graphics.Quad_Vertex_2D {
			position         = {position.x, position.y + offset + descent, 0},
			size             = vmath.vec2(char.texture_size) * scale,
			color            = cmd.color,
			texture_position = vmath.vec2(char.texture_offset) / font.atlas_size,
			texture_size     = vmath.vec2(char.texture_size) / font.atlas_size,
			texture          = font.texture,
		}

		// flip y
		// vertex.texture_position.y += vertex.texture_size.y
		// vertex.texture_size.y *= -1

		append(&renderer.buffer, vertex)

		advance := char.advance
		if i < len(cmd.text) - 1 {
			next_code_point := rune(cmd.text[i + 1])
			pair := graphics.get_kern_pair(code_point, next_code_point)
			if pair in font.kern_lookup {
				advance += font.kern_lookup[pair]
			}
		}

		position.x += f32(char.advance) * char.scale * scale
	}
}
