package ecs

import "core:slice"
View :: struct {
	registry: ^Registry,
	types:    [dynamic]typeid,
}

create_view :: proc(registry: ^Registry, types: ..typeid) -> View {
	view := View{}

	view.registry = registry
	view.types = slice.clone_to_dynamic(types)

	return view
}

iterate_view :: proc(view: ^View, call_back_context: $T, call_back: proc(ctx: T, e: Entity)) {

	// if only one type
	if len(view.types) <= 0 {
		return
	}

	if len(view.types) <= 1 {
		// iterate componetn set data array (iterate dense and then index into data as its not castable to a typeid as it is stored tpye erased)
		component_set := _get_component_set_by_typeid(view.registry, view.types[0])
		for entity in component_set.dense {
			call_back(call_back_context, Entity(entity))
		}
		return
	}

	// if multiple


	// get smallest componet set
	smallest_component_set: ^Sparse_Set = nil
	other_component_sets: [dynamic]^Sparse_Set

	for type in view.types {
		component_set := _get_component_set_by_typeid(view.registry, type)

		if len(component_set.dense) < len(smallest_component_set.dense) {
			append(&other_component_sets, smallest_component_set)
			smallest_component_set = component_set
		} else {
			append(&other_component_sets, component_set)
		}
	}

	// iterate component set dense (desnse stroes indexes into sparse)
	for entity in smallest_component_set.dense {
		_run_call_back_on_entity(entity, other_component_sets[:], call_back_context, call_back)
	}
}

_run_call_back_on_entity :: proc(
	entity: Entity,
	component_sets: []^Sparse_Set,
	call_back_context: $T,
	call_back: proc(ctx: T, e: Entity),
) {
	// for each dense entry check against all other component sets (using the spares index found in dense)
	for component_set in component_sets {
		// if one set doesnt contain the entity discard and move on
		if !sparse_set_contains(component_set, entity) {
			return
		}
	}

	// otherwise run the call_back on the entity
	call_back(call_back_context, Entity(entity))
}
