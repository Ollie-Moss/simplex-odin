package ecs

PAGE_SIZE :: 1024

Page :: [PAGE_SIZE]u32

Sparse_Array :: struct {
	pages: [dynamic]^Page,
}

_sparse_array_get_page :: proc(sparse_array: ^Sparse_Array, index: u32) -> (^Page, u32) {
	page_index := index / PAGE_SIZE
	index_into_page := index % PAGE_SIZE
	if page_index >= u32(len(sparse_array.pages)) {

		old_len := u32(len(sparse_array.pages))
		resize_dynamic_array(&sparse_array.pages, page_index + 1)

		for i in old_len ..= page_index {
			page := new(Page)
			for j in 0 ..< PAGE_SIZE {
				page[j] = NULL_INDEX
			}
			sparse_array.pages[i] = page
		}
	}

	page := sparse_array.pages[page_index]
	return page, index_into_page
}


sparse_array_make :: proc() -> Sparse_Array {
	return Sparse_Array{}
}

sparse_array_delete :: proc(sparse_array: ^Sparse_Array) {
	for page in sparse_array.pages {
		free(page)
	}
}

sparse_array_set :: proc(sparse_array: ^Sparse_Array, index: u32, value: u32) {
	page, index := _sparse_array_get_page(sparse_array, index)
	page[index] = value
}

sparse_array_get :: proc(sparse_array: ^Sparse_Array, index: u32) -> u32 {
	page, index := _sparse_array_get_page(sparse_array, index)

	return page[index]
}
