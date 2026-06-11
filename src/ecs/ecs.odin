package ecs

import "core:container/queue"

Entity :: u32

View :: struct {}

MAX_ENTITIES :: 1_000_000

Registry :: struct {
	entity_list:         queue.Queue(Entity),
	component_sets:      [dynamic]rawptr,
	component_set_types: map[typeid]int,
}

make_registry :: proc() -> Registry {
	registry: Registry = Registry{}
	for i := 0; i < MAX_ENTITIES - 1; i += 1 {
		queue.push_back(&registry.entity_list, Entity(i))
	}

	return registry
}

_register_component_type :: proc(registry: ^Registry, $T: typeid) {
	append(&registry.component_sets, rawptr(make_sparse_set(T)))
	registry.component_set_types[T] = len(registry.component_sets) - 1
}

_get_component_set :: proc(registry: ^Registry, $T: typeid) -> ^Sparse_Set(T) {
	if T not_in registry.component_set_types {
		_register_component_type(registry, T)
	}

	index := registry.component_set_types[T]
	component_set := registry.component_sets[index]

	return cast(^Sparse_Set(T))component_set
}

create_entity :: proc(registry: ^Registry) -> Entity {
	return queue.pop_back(&registry.entity_list)
}

destroy_entity :: proc(registry: ^Registry, entity: Entity) {
	queue.push_back(&registry.entity_list, entity)
}

emplace_component :: proc(registry: ^Registry, entity: Entity, component: $T) {
	component_set := _get_component_set(registry, T)
	sparse_set_insert(component_set, entity, component)
}

get_component :: proc(registry: ^Registry, entity: Entity, $T: typeid) -> ^T {
	component_set := _get_component_set(registry, T)
	return sparse_set_get(component_set, entity)
}

remove_component :: proc(registry: ^Registry, entity: Entity, $T: typeid) {
	component_set := _get_component_set(registry, T)
	sparse_set_remove(component_set, entity)
}

create_view :: proc(registry: ^Registry, types: ..typeid) -> View {
	return View{}
}

iterate_view :: proc(view: ^View, call_back: proc(e: Entity)) {}
