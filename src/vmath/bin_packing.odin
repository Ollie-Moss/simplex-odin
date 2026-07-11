package vmath

import "core:fmt"
import "vendor:stb/rect_pack"

main :: proc() {
	bin := Rect {
		size     = {100, 100},
		position = {0, 0},
	}

	rects_to_pack := []Rect {
		Rect{size = {50, 50}, position = {0, 0}},
		Rect{size = {50, 50}, position = {0, 0}},
		Rect{size = {25, 50}, position = {0, 0}},
		Rect{size = {10, 5}, position = {0, 0}},
	}


	packed, _ := bin_pack(bin, rects_to_pack)
	fmt.println(packed)
}

Rect :: struct {
	size:     ivec2,
	position: ivec2,
}

bin_pack :: proc(bin: Rect, rects: []Rect) -> (packed: []Rect, ok: bool) {
	free_rects: [dynamic]Rect
	append(&free_rects, bin)

	for &rect in rects {

		target_index: int = -1
		max_area := max(i32)
		for i := 0; i < len(free_rects); i += 1 {
			free_rect := free_rects[i]
			area := free_rect.size.x * free_rect.size.y
			if area < max_area &&
			   rect.size.x <= free_rect.size.x &&
			   rect.size.y <= free_rect.size.y {
				target_index = i
			}
		}

		if target_index == -1 {
			return nil, false
		}

		// insert
		free_rect := free_rects[target_index]
		rect.position = free_rect.position
		fmt.println("inserting, free: ", free_rect, ", inserted: ", rect)
		for i := len(free_rects) - 1; i >= 0; i -= 1 {
			f := free_rects[i]
			if !intersects(f, rect) {
				continue
			}
			unordered_remove(&free_rects, i)

			// left slice
			if rect.position.x > f.position.x {
				append(
					&free_rects,
					Rect{position = f.position, size = {rect.position.x - f.position.x, f.size.y}},
				)
			}
			// right slice
			if f.position.x + f.size.x > rect.position.x + rect.size.x {
				append(
					&free_rects,
					Rect {
						position = {rect.position.x + rect.size.x, f.position.y},
						size = {
							f.position.x + f.size.x - (rect.position.x + rect.size.x),
							f.size.y,
						},
					},
				)
			}
			// bottom slice
			if rect.position.y > f.position.y {
				append(
					&free_rects,
					Rect{position = f.position, size = {f.size.x, rect.position.y - f.position.y}},
				)
			}
			// top slice
			if f.position.y + f.size.y > rect.position.y + rect.size.y {
				append(
					&free_rects,
					Rect {
						position = {f.position.x, rect.position.y + rect.size.y},
						size = {
							f.size.x,
							f.position.y + f.size.y - (rect.position.y + rect.size.y),
						},
					},
				)
			}
		}

		// resconsilate
		// remove fully contained rects
		for i := len(free_rects) - 1; i >= 0; i -= 1 {
			for j := len(free_rects) - 1; j >= 0; j -= 1 {
				if i == j {
					continue
				}

				r1 := free_rects[i]
				r2 := free_rects[j]
				// check if r2 is fully contained in r1
				if is_contained(r1, r2) {
					unordered_remove(&free_rects, j)
					j -= 1
				}

			}
		}
	}

	return rects, true
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
	r2_br := r2.position
	r2_tr := r2.position + r2.size
	return(
		(r2_br.x >= r1.position.x && r2_br.x <= r1.position.x + r1.size.x) &&
		(r2_br.y >= r1.position.y && r2_br.y <= r1.position.y + r1.size.y) &&
		(r2_tr.x >= r1.position.x && r2_tr.x <= r1.position.x + r1.size.x) &&
		(r2_tr.y >= r1.position.y && r2_tr.y <= r1.position.y + r1.size.y) \
	)
}
