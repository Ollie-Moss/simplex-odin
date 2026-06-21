package ecs

View :: struct {}

create_view :: proc(registry: ^Registry, types: ..typeid) -> View {
	return View{}
}

iterate_view :: proc(view: ^View, call_back: proc(e: Entity)) {}
