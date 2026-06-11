package ecs

import "core:fmt"
NULL_INDEX :: -1

PAGE_SIZE :: 1024

Page :: [PAGE_SIZE]u32

Sparse_Array :: struct {
	pages: [dynamic]^Page,
}

_sparse_array_make :: proc() -> Sparse_Array {
	return Sparse_Array{}
}


_sparse_array_delete :: proc(sparse_array: ^Sparse_Array) {
	for page in sparse_array.pages {
		free(page)
	}
}

_sparse_array_get_page :: proc(sparse_array: ^Sparse_Array, index: u32) -> (^Page, u32) {
	page_index := index / PAGE_SIZE
	index_into_page := index % PAGE_SIZE

	if page_index >= u32(len(sparse_array.pages)) {
		resize_dynamic_array(&sparse_array.pages, page_index + 1)

		page := new(Page)
		sparse_array.pages[page_index] = page
	}

	page := sparse_array.pages[page_index]

	return page, index_into_page
}

_sparse_array_set :: proc(sparse_array: ^Sparse_Array, index: u32, value: u32) {
	page, index := _sparse_array_get_page(sparse_array, index)
	page[index] = value
}

_sparse_array_get :: proc(sparse_array: ^Sparse_Array, index: u32) -> u32 {
	page, index := _sparse_array_get_page(sparse_array, index)

	return page[index]
}

Sparse_Set :: struct($T: typeid) {
	sparse: Sparse_Array,
	dense:  [dynamic]u32,
	data:   [dynamic]T,
}

make_sparse_set :: proc($T: typeid) -> ^Sparse_Set(T) {
	sparse_set: ^Sparse_Set(T) = new(Sparse_Set(T))
	sparse_set.sparse = _sparse_array_make()
	return sparse_set
}

sparse_set_delete :: proc(sparse_set: ^Sparse_Set($T)) {
	_sparse_array_delete(sparse_set.sparse)
	free(sparse_set)
}

sparse_set_insert :: proc(sparse_set: ^Sparse_Set($T), index: u32, value: T) {
	append(&sparse_set.dense, index)
	append(&sparse_set.data, value)

	dense_index: u32 = u32(len(sparse_set.dense) - 1)

	_sparse_array_set(&sparse_set.sparse, index, dense_index)
}

sparse_set_get :: proc(sparse_set: ^Sparse_Set($T), index: u32) -> ^T {
	dense_index := _sparse_array_get(&sparse_set.sparse, index)
	return &sparse_set.data[dense_index]
}

sparse_set_remove :: proc(sparse_set: Sparse_Set($T), index: u32) {
	dense_index := _sparse_array_get(sparse_set.sparse, index)

	back_pos := len(sparse_set.dense) - 1
	back_key := sparse_set.dense[back_pos]

	sparse_set.dense[dense_index] = dense[back_pos]
	sparse_set.data[dense_index] = dense[back_pos]

	_sparse_array_set(sparse_set.sparse, back_key, dense_index)

	pop(&s.dense)
	pop(&s.data)

	_sparse_array_set(sparse_set.sparse, index, NULL_INDEX)
}
