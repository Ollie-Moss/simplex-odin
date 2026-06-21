package ecs

emplace_component :: proc(registry: ^Registry, entity: Entity, component: $T) {
	component_set := _get_component_set(registry, T)
	sparse_set_insert(component_set, entity, component)
}

get_component :: proc(registry: ^Registry, entity: Entity, $T: typeid) -> ^T {
	component_set := _get_component_set(registry, T)
	return sparse_set_get(component_set, entity, T)
}

try_get_component :: proc(
	registry: ^Registry,
	entity: Entity,
	$T: typeid,
) -> (
	component: ^T,
	ok: bool,
) {
	component_set := _get_component_set(registry, T)
	return sparse_set_try_get(component_set, entity, T)
}

remove_component :: proc(registry: ^Registry, entity: Entity, $T: typeid) {
	component_set := _get_component_set(registry, T)
	sparse_set_try_remove(component_set, entity)
}

try_remove_component :: proc(registry: ^Registry, entity: Entity, $T: typeid) -> (ok: bool) {
	component_set := _get_component_set(registry, T)
	return sparse_set_try_remove(component_set, entity)
}
