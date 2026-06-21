package ecs

MAX_ENTITIES :: 1_000_000

Registry :: struct {
	entity_set:          ^Sparse_Set,
	next_new_entity:     Entity,
	free_entities:       [dynamic]Entity,
	component_sets:      [dynamic]^Sparse_Set,
	component_set_types: map[typeid]int,
}

make_registry :: proc() -> Registry {
	registry: Registry = Registry{}
	registry.entity_set = make_sparse_set(struct {})
	registry.next_new_entity = 0
	return registry
}

_register_component_type :: proc(registry: ^Registry, $T: typeid) {
	append(&registry.component_sets, make_sparse_set(T))
	registry.component_set_types[T] = len(registry.component_sets) - 1
}

_get_component_set :: proc(registry: ^Registry, $T: typeid) -> ^Sparse_Set {
	if T not_in registry.component_set_types {
		_register_component_type(registry, T)
	}

	index := registry.component_set_types[T]
	component_set := registry.component_sets[index]

	return cast(^Sparse_Set)component_set
}

_get_component_set_by_typeid :: proc(registry: ^Registry, T: typeid) -> ^Sparse_Set {
	if T not_in registry.component_set_types {
		panic("AHHHH NO COMPONENT TYPE REGISTERED")
	}

	index := registry.component_set_types[T]
	component_set := registry.component_sets[index]

	return cast(^Sparse_Set)component_set
}
