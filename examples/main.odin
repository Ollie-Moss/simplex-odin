package example_simplex

import core "../src/core/"


main :: proc() {

	simplex := core.Simplex {
		options = {
			windowOptions = {windowSize = {640, 480}, title = "Simplex"},
			backgroundColor = {0.173, 0.169, 0.180, 1.00},
		},
	}

	core.init(&simplex)

	core.start(&simplex)

	core.shutdown(&simplex)
}
