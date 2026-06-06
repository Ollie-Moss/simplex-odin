package simplex

import "../input"
import "../view"

SimplexOptions :: struct {
	windowOptions: view.WindowOptions,
}

window: view.Window

init :: proc(options: SimplexOptions) {
	view.init()

	window = view.setup_window(options.windowOptions)

	for !view.should_quit(window) {
		view.update(window)
		input.update()
	}
}

shutdown :: proc() {
	view.close_window(window)
}
