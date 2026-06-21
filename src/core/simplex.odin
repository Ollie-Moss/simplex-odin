package simplex

import "core:fmt"
import "simplex:assets"
import "simplex:ecs"
import "simplex:graphics"
import "simplex:input"
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

physics_system :: proc(simplex: ^Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	transform.position.y -= 0.05
}

render_system :: proc(simplex: ^Simplex, entity: ecs.Entity) {
	transform := ecs.get_component(&simplex.registry, entity, vmath.Transform)
	graphics.sumbit_command(&simplex.renderer, {transform = transform^})
}


start :: proc(simplex: ^Simplex) {

	for i in 0 ..< 10 {
		entity := ecs.create_entity(&simplex.registry)
		ecs.emplace_component(
			&simplex.registry,
			entity,
			vmath.Transform{position = {10 + f32(60 * i), 300, 0}, size = {50, 50, 0}},
		)
	}

	physics_view := ecs.create_view(&simplex.registry, vmath.Transform)
	render_view := ecs.create_view(&simplex.registry, vmath.Transform)

	for !view.should_quit(simplex.window) {
		input.update()

		ecs.iterate_view(&physics_view, simplex, physics_system)
		ecs.iterate_view(&render_view, simplex, render_system)

		graphics.clear_color(simplex.options.backgroundColor)
		graphics.render(&simplex.renderer, &simplex.asset_registry, view.view__window_size)
		view.update(simplex.window)
	}
}

shutdown :: proc(simplex: ^Simplex) {
	destroy_simplex(simplex)

	view.close_window(simplex.window)
}
