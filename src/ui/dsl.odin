package ui

build :: proc(childrenCount: i32) -> Node_Desc {
	return Node_Desc{}
}

reconcile :: proc(root: Node_Desc, retained_root: Node) -> Node {
	return retained_root
}


pixels :: proc(amount: f32) -> Length {
	return {.Pixels, amount}
}

percent :: proc(amount: f32) -> Length {
	return {.Percent, amount}
}
