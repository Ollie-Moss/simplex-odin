package simplex

import "../graphics"
import "../input"
import "../view"
import "../vmath"

SimplexOptions :: struct {
	windowOptions:   view.WindowOptions,
	backgroundColor: vmath.vec4,
}

Simplex :: struct {
	window:  view.Window,
	options: SimplexOptions,
}


init :: proc(simplex: ^Simplex) {
	view.init()
	simplex.window = view.create_window(simplex.options.windowOptions)

	graphics.init()

}

start :: proc(simplex: ^Simplex) {
	for !view.should_quit(simplex.window) {
		input.update()

		graphics.sumbit_command({transform = {position = {0, 0, 0}, size = {0.5, 1, 0}}})
		graphics.clear_color(simplex.options.backgroundColor)
		graphics.draw_all()
		view.update(simplex.window)
	}
}

shutdown :: proc(simplex: ^Simplex) {
	view.close_window(simplex.window)
}
