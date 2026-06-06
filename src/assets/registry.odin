package assets

import "core:container/handle_map"
import "core:fmt"
Asset_Handle :: distinct u32 // index into the asset list data

Asset_List :: struct {
	data:    [dynamic]any,
	destroy: proc(data: rawptr), // optional cleanup
}

make_asset_list :: proc($T: typeid, destroy: proc(_: rawptr) = nil) -> Asset_List {
	return Asset_List{data = make([dynamic]any), destroy = destroy}
}
destroy_asset_list :: proc(list: Asset_List) {
	delete(list.data)
}

Asset_Registry :: struct {
	asset_lists:        [dynamic]Asset_List,
	type_to_asset_list: map[typeid]u32,
}

make_registry :: proc() -> Asset_Registry {
	return Asset_Registry {
		asset_lists = make([dynamic]Asset_List),
		type_to_asset_list = make(map[typeid]u32),
	}
}

destroy_registry :: proc(registry: ^Asset_Registry) {
	for &list in registry.asset_lists {
		if list.destroy != nil {
			for &item in list.data {
				list.destroy(item.data) // item is `any`, .data is rawptr
			}
		}
		for item in list.data {
			free(item.data)
		}
		destroy_asset_list(list)
	}
	delete(registry.asset_lists)
	delete(registry.type_to_asset_list)
}

register_asset_list :: proc(
	registry: ^Asset_Registry,
	$T: typeid,
	destroy: proc(_: rawptr) = nil,
) {
	if T in registry.type_to_asset_list {
		return
	}

	asset_list := make_asset_list(T, destroy)

	append(&registry.asset_lists, asset_list)

	map_insert(&registry.type_to_asset_list, T, u32(len(registry.asset_lists) - 1))
}

get_asset :: proc(registry: ^Asset_Registry, $T: typeid, handle: Asset_Handle) -> ^T {
	asset_list_index := registry.type_to_asset_list[T]
	asset_list := &registry.asset_lists[asset_list_index]

	asset := &asset_list.data[handle]
	assert(asset.id == T, "Handle is associate with a different type than expected")

	return cast(^T)asset.data
}

insert_asset :: proc(registry: ^Asset_Registry, data: $T) -> Asset_Handle {
	if T not_in registry.type_to_asset_list {
		register_asset_list(registry, T)
	}

	asset_list_index := registry.type_to_asset_list[T]
	asset_list := &registry.asset_lists[asset_list_index]

	ptr := new(T)
	ptr^ = data
	append(&asset_list.data, any{data = ptr, id = typeid_of(T)})

	return Asset_Handle(len(asset_list.data) - 1)
}
