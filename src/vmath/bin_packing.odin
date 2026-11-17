package vmath

Rect :: struct {
	size:     ivec2,
	position: ivec2,
}

pack_rect :: proc(
	free_rects: ^[dynamic]Rect,
	rect_to_pack: Rect,
) -> (
	packed_rect: Rect,
	ok: bool,
) {
	rect := rect_to_pack

	target_index: int = -1
	max_area := max(i32)
	for i := 0; i < len(free_rects); i += 1 {
		free_rect := free_rects[i]
		area := free_rect.size.x * free_rect.size.y
		if area < max_area && rect.size.x <= free_rect.size.x && rect.size.y <= free_rect.size.y {
			target_index = i
			max_area = area
		}
	}

	if target_index == -1 {
		return Rect{}, false
	}

	// insert
	free_rect := free_rects[target_index]
	rect.position = free_rect.position
	//fmt.println("inserting, free: ", free_rect, ", inserted: ", rect)
	#reverse for f, i in free_rects {
		if !intersects(f, rect) {
			continue
		}
		unordered_remove(free_rects, i)
		new_rects := [4]Rect{}
		new_rects_count := 0

		// left slice
		if rect.position.x > f.position.x {
			new_rects[new_rects_count] = Rect {
				position = f.position,
				size     = {rect.position.x - f.position.x, f.size.y},
			}
			new_rects_count += 1

		}
		// right slice
		if f.position.x + f.size.x > rect.position.x + rect.size.x {
			new_rects[new_rects_count] = Rect {
				position = {rect.position.x + rect.size.x, f.position.y},
				size     = {f.position.x + f.size.x - (rect.position.x + rect.size.x), f.size.y},
			}
			new_rects_count += 1
		}
		// bottom slice
		if rect.position.y > f.position.y {
			new_rects[new_rects_count] = Rect {
				position = f.position,
				size     = {f.size.x, rect.position.y - f.position.y},
			}
			new_rects_count += 1
		}
		// top slice
		if f.position.y + f.size.y > rect.position.y + rect.size.y {
			new_rects[new_rects_count] = Rect {
				position = {f.position.x, rect.position.y + rect.size.y},
				size     = {f.size.x, f.position.y + f.size.y - (rect.position.y + rect.size.y)},
			}
			new_rects_count += 1
		}

		for j := 0; j < new_rects_count; j += 1 {
			contained := false
			new_rect := new_rects[j]

			for free_rect in free_rects {
				// check if r2 is fully contained in r1
				if is_contained(free_rect, new_rect) {
					contained = true
					break
				}
			}
			if !contained {
				append(free_rects, new_rect)
			}
		}
	}
	return rect, true
}
intersects :: proc(r1: Rect, r2: Rect) -> bool {
	return(
		r1.position.x < r2.position.x + r2.size.x &&
		r1.position.x + r1.size.x > r2.position.x &&
		r1.position.y < r2.position.y + r2.size.y &&
		r1.position.y + r1.size.y > r2.position.y \
	)
}

is_contained :: proc(r1: Rect, r2: Rect) -> bool {
	return(
		r2.position.x >= r1.position.x &&
		r2.position.y >= r1.position.y &&
		r2.position.x + r2.size.x <= r1.position.x + r1.size.x &&
		r2.position.y + r2.size.y <= r1.position.y + r1.size.y \
	)
}

area :: proc(rect: Rect) -> i32 {
	return rect.size.x * rect.size.y
}
