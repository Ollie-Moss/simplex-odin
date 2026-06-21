package ecs

import "base:runtime"
import "core:mem"

NULL_INDEX :: max(u32)

Sparse_Set :: struct {
	sparse:    Sparse_Array,
	dense:     [dynamic]u32,
	data:      rawptr, // ^[dynamic]T
	data_size: u32,
	data_id:   typeid,
}

_raw_data :: proc(sparse_set: ^Sparse_Set) -> ^runtime.Raw_Dynamic_Array {
	return cast(^runtime.Raw_Dynamic_Array)sparse_set.data
}

make_sparse_set :: proc($T: typeid) -> ^Sparse_Set {
	sparse_set := new(Sparse_Set)
	sparse_set.sparse = sparse_array_make()
	arr := new([dynamic]T)
	arr^ = make([dynamic]T)
	sparse_set.data = arr
	sparse_set.data_size = size_of(T)
	sparse_set.data_id = typeid_of(T)
	return sparse_set
}

sparse_set_contains :: proc(sparse_set: ^Sparse_Set, index: u32) -> bool {
	return sparse_array_get(&sparse_set.sparse, index) != NULL_INDEX
}

sparse_set_insert :: proc(sparse_set: ^Sparse_Set, index: u32, value: $T) {
	assert(sparse_set.data_id == typeid_of(T))
	arr := cast(^[dynamic]T)sparse_set.data

	append(&sparse_set.dense, index)
	append(arr, value)
	dense_index := u32(len(sparse_set.dense) - 1)
	sparse_array_set(&sparse_set.sparse, index, dense_index)
}

sparse_set_get :: proc(sparse_set: ^Sparse_Set, index: u32, $T: typeid) -> ^T {
	assert(sparse_set_contains(sparse_set, index))
	return _sparse_set_get_impl(sparse_set, index, T)
}

sparse_set_try_get :: proc(
	sparse_set: ^Sparse_Set,
	index: u32,
	$T: typeid,
) -> (
	data: ^T,
	ok: bool,
) {
	if !sparse_set_contains(sparse_set, index) {
		return nil, false
	}
	return _sparse_set_get_impl(sparse_set, index, T), true
}

_sparse_set_get_impl :: proc(sparse_set: ^Sparse_Set, index: u32, $T: typeid) -> ^T {
	assert(sparse_set.data_id == typeid_of(T))
	arr := cast(^[dynamic]T)sparse_set.data

	dense_index := sparse_array_get(&sparse_set.sparse, index)
	assert(dense_index != NULL_INDEX)
	return &arr[dense_index]
}

sparse_set_remove :: proc(sparse_set: ^Sparse_Set, index: u32) {
	assert(sparse_set_contains(sparse_set, index))

	_sparse_set_remove_impl(sparse_set, index)
}

sparse_set_try_remove :: proc(sparse_set: ^Sparse_Set, index: u32) -> (ok: bool) {
	if !sparse_set_contains(sparse_set, index) {
		return false
	}

	_sparse_set_remove_impl(sparse_set, index)
	return false
}

_sparse_set_remove_impl :: proc(sparse_set: ^Sparse_Set, index: u32) {
	dense_index := sparse_array_get(&sparse_set.sparse, index)

	back_pos := u32(len(sparse_set.dense) - 1)
	back_key := sparse_set.dense[back_pos]

	sparse_set.dense[dense_index] = sparse_set.dense[back_pos]

	raw := _raw_data(sparse_set)
	elem_size := uintptr(sparse_set.data_size)
	base := uintptr(raw.data)

	dst := rawptr(base + uintptr(dense_index) * elem_size)
	src := rawptr(base + uintptr(back_pos) * elem_size)
	mem.copy(dst, src, int(elem_size))

	sparse_array_set(&sparse_set.sparse, back_key, dense_index)

	pop(&sparse_set.dense)
	raw.len -= 1

	sparse_array_set(&sparse_set.sparse, index, NULL_INDEX)
}

sparse_set_delete :: proc(sparse_set: ^Sparse_Set) {
	raw := _raw_data(sparse_set)
	if raw.data != nil {
		free(raw.data, raw.allocator)
	}
	free(sparse_set.data)
	sparse_array_delete(&sparse_set.sparse)
	delete(sparse_set.dense)
	free(sparse_set)
}
