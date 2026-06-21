package ecs

Entity :: u32

create_entity :: proc(registry: ^Registry) -> Entity {
	entity: Entity
	if len(registry.free_entities) > 0 {
		entity = pop(&registry.free_entities)
	} else {
		entity = registry.next_new_entity
		registry.next_new_entity += 1
	}
	sparse_set_insert(registry.entity_set, entity, struct{}{})
	return entity
}

destroy_entity :: proc(registry: ^Registry, entity: Entity) {
	for component_type, component_set_index in registry.component_set_types {
		component_set := registry.component_sets[component_set_index]
		sparse_set_remove(component_set, entity)
	}
	sparse_set_remove(registry.entity_set, entity)
	append(&registry.free_entities, entity)
}

valid_entity :: proc(registry: ^Registry, entity: Entity) -> bool {
	if entity >= MAX_ENTITIES {
		return false
	}
	return sparse_set_contains(registry.entity_set, entity)
}
