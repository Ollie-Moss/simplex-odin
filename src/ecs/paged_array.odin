package ecs

PAGE_SIZE :: 4096

Page :: [PAGE_SIZE]u32

Paged_Array :: struct {
	pages: [dynamic]^Page,
}

paged_array_make :: proc() -> Paged_Array {
	return Paged_Array{}
}

paged_array_delete :: proc(sparse_array: ^Paged_Array) {
	for page in sparse_array.pages {
		if page != nil {
			free(page)
		}
	}
	delete(sparse_array.pages)
}

paged_array_get :: proc(sparse_array: ^Paged_Array, index: u32) -> u32 {
	page_index := index / PAGE_SIZE
	if page_index >= u32(len(sparse_array.pages)) {
		return NULL_INDEX
	}
	page := sparse_array.pages[page_index]
	if page == nil {
		return NULL_INDEX
	}
	return page[index % PAGE_SIZE]
}

paged_array_set :: proc(sparse_array: ^Paged_Array, index: u32, value: u32) {
	page_index := index / PAGE_SIZE
	index_into_page := index % PAGE_SIZE

	if page_index >= u32(len(sparse_array.pages)) {
		resize_dynamic_array(&sparse_array.pages, int(page_index) + 1)
		// new slots are already nil (zero value for pointers)
	}

	page := sparse_array.pages[page_index]
	if page == nil {
		page = new(Page)
		for &v in page {
			v = NULL_INDEX
		}
		sparse_array.pages[page_index] = page
	}

	page[index_into_page] = value
}
