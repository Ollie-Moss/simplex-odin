#+feature dynamic-literals
package todo_app

import "simplex:assets"
import "simplex:graphics"
import "simplex:input"
import "simplex:ui"
import "simplex:ui_host"
import "simplex:view"
import "simplex:vmath"

main :: proc() {
	backgroundColor := vmath.vec4{0.173, 0.169, 0.180, 1.00}
	windowOptions := view.Window_Options {
		windowSize = {1280, 720},
		title      = "Simplex",
	}

	view.init()
	window := view.create_window(windowOptions)
	defer view.close_window(window)

	graphics.init()

	input.init(window.windowHandle)

	asset_registry := assets.make_registry()
	defer assets.destroy_registry(&asset_registry)

	font := graphics.load_font(&asset_registry, {path = "fonts/arial.ttf"})

	spriteShader := graphics.load_shader(
		&asset_registry,
		{vertexPath = "src/shaders/sprite.vert", fragmentPath = "src/shaders/sprite.frag"},
	)

	ui_renderer := graphics.make_renderer_2D(spriteShader)
	defer graphics.destroy_renderer_2d(&ui_renderer)

	font_provider := ui_host.make_font_provider(&asset_registry)
	defer ui_host.delete_font_provider(font_provider)
	backend := ui_host.make_backend(font_provider)

	tree := ui.make_tree(backend)
	defer ui.delete_tree(tree)

	ui_host.store_font(font_provider, "Arial", font)

	for !view.should_quit(window) {

		input.update(window.windowHandle)

		ui_view := ui.column(
			ui.Style {
				width_mode = .Grow,
				height_mode = .Grow,
				color = ui.hex(0x121211),
				padding = {10, 10, 10, 10},
				gap = 12,
			},
			ui.row(
				ui.Style{main_align = .Center, width_mode = .Grow, height_mode = .Grow, color = ui.hex(0x262624)}, // header
				ui.label("Hello, World!", {width_mode = .Hug, color = {0, 0, 0, 0}}),
			),
			ui.element(
				ui.Style{width_mode = .Grow, color = ui.hex(0x262624)}, // content
				ui.show(input.is_held_mouse(.Mouse1), ui.label("Mouse Held")),
			),
		)

		surface_size := vmath.vec2(view.get_window_size(&window))

		ui.reconcile(tree, ui_view)
		ui.layout(tree, surface_size)
		cmd_buf := make([dynamic]ui.Render_Command, context.temp_allocator)
		ui.render(tree.root, &cmd_buf)
		ui_host.render_ui(&ui_renderer, font_provider, &cmd_buf)

		graphics.clear_color(backgroundColor)

		graphics.render(
			&ui_renderer,
			&asset_registry,
			graphics.calculate_projection(vmath.vec2(view.get_window_size(&window))),
		)
		view.update(window)

		free_all(context.temp_allocator)
	}
}
