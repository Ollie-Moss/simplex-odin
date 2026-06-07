package example_simplex

import "simplex:core"

main :: proc() {

	simplex := core.make_simplex(
		{
			windowOptions = {windowSize = {640, 480}, title = "Simplex"},
			backgroundColor = {0.173, 0.169, 0.180, 1.00},
		},
	)

	core.init(&simplex)

	core.start(&simplex)

	core.shutdown(&simplex)
}
