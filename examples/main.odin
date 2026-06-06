package example_simplex

import simplex "../src/core/"


main :: proc() {
	options := simplex.SimplexOptions {
		windowOptions = {windowSize = {640, 480}, title = "Simplex"},
	}

	simplex.init(options)
	simplex.shutdown()
}
