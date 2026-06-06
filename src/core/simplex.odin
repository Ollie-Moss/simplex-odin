package simplex

import "../graphics"
import "../input"
import "../view"

SimplexOptions :: struct {
	windowOptions: view.WindowOptions,
}

window: view.Window

init :: proc(options: SimplexOptions) {
	view.init()
	window = view.setup_window(options.windowOptions)

	graphics.init()

	for !view.should_quit(window) {
		input.update()

		graphics.sumbit_command({transform = {position = {0, 0, 0}, size = {0.5, 1, 0}}})
		graphics.clear_color({0.173, 0.169, 0.180, 1.00})
		graphics.draw_all()
		view.update(window)
	}
}

shutdown :: proc() {
	view.close_window(window)
}
