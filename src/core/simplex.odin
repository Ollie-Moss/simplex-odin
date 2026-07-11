package simplex

import "simplex:assets"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:view"
import "simplex:vmath"

Simplex_Options :: struct {
	windowOptions:   view.Window_Options,
	backgroundColor: vmath.vec4,
}

Simplex :: struct {
	window:         view.Window,
	options:        Simplex_Options,
	asset_registry: assets.Asset_Registry,
	renderer:       graphics.BatchRenderer2D,
	registry:       ecs.Registry,
}

make_simplex :: proc(options: Simplex_Options) -> Simplex {
	return Simplex{options = options}
}

destroy_simplex :: proc(simplex: ^Simplex) {
	assets.destroy_registry(&simplex.asset_registry)
	graphics.destroy_renderer_2d(&simplex.renderer)
}

init :: proc(simplex: ^Simplex) {
	view.init()
	simplex.window = view.create_window(simplex.options.windowOptions)
	simplex.registry = ecs.make_registry()
	graphics.init()

	simplex.asset_registry = assets.make_registry()

	spriteShader := graphics.load_shader(
		&simplex.asset_registry,
		{vertexPath = "src/shaders/sprite.vert", fragmentPath = "src/shaders/sprite.frag"},
	)

	texture := graphics.load_texture(&simplex.asset_registry, {path = "sprites/grass_tile_1.png"})

	simplex.renderer = graphics.make_renderer_2D(spriteShader, texture)
}

should_quit :: proc(simplex: ^Simplex) -> bool {
	return view.should_quit(simplex.window)
}

shutdown :: proc(simplex: ^Simplex) {
	destroy_simplex(simplex)

	view.close_window(simplex.window)
}
