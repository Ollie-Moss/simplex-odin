package ecs

// Views support upto 8 component types. Add more if you want

View1 :: struct($A: typeid) {
	registry: ^Registry,
}

View2 :: struct($A: typeid, $B: typeid) {
	registry: ^Registry,
}

View3 :: struct($A: typeid, $B: typeid, $C: typeid) {
	registry: ^Registry,
}

View4 :: struct($A: typeid, $B: typeid, $C: typeid, $D: typeid) {
	registry: ^Registry,
}

View5 :: struct($A: typeid, $B: typeid, $C: typeid, $D: typeid, $E: typeid) {
	registry: ^Registry,
}

View6 :: struct($A: typeid, $B: typeid, $C: typeid, $D: typeid, $E: typeid, $F: typeid) {
	registry: ^Registry,
}

View7 :: struct(
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
	$E: typeid,
	$F: typeid,
	$G: typeid,
) {
	registry: ^Registry,
}

View8 :: struct(
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
	$E: typeid,
	$F: typeid,
	$G: typeid,
	$H: typeid,
) {
	registry: ^Registry,
}

create_view :: proc {
	create_view1,
	create_view2,
	create_view3,
	create_view4,
	create_view5,
	create_view6,
	create_view7,
	create_view8,
}

create_view1 :: proc(registry: ^Registry, $A: typeid) -> View1(A) {
	return View1(A){registry = registry}
}

create_view2 :: proc(registry: ^Registry, $A: typeid, $B: typeid) -> View2(A, B) {
	return View2(A, B){registry = registry}
}

create_view3 :: proc(registry: ^Registry, $A: typeid, $B: typeid, $C: typeid) -> View3(A, B, C) {
	return View3(A, B, C){registry = registry}
}

create_view4 :: proc(
	registry: ^Registry,
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
) -> View4(A, B, C, D) {
	return View4(A, B, C, D){registry = registry}
}

create_view5 :: proc(
	registry: ^Registry,
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
	$E: typeid,
) -> View5(A, B, C, D, E) {
	return View5(A, B, C, D, E){registry = registry}
}

create_view6 :: proc(
	registry: ^Registry,
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
	$E: typeid,
	$F: typeid,
) -> View6(A, B, C, D, E, F) {
	return View6(A, B, C, D, E, F){registry = registry}
}

create_view7 :: proc(
	registry: ^Registry,
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
	$E: typeid,
	$F: typeid,
	$G: typeid,
) -> View7(A, B, C, D, E, F, G) {
	return View7(A, B, C, D, E, F, G){registry = registry}
}

create_view8 :: proc(
	registry: ^Registry,
	$A: typeid,
	$B: typeid,
	$C: typeid,
	$D: typeid,
	$E: typeid,
	$F: typeid,
	$G: typeid,
	$H: typeid,
) -> View8(A, B, C, D, E, F, G, H) {
	return View8(A, B, C, D, E, F, G, H){registry = registry}
}

iterate_view :: proc {
	iterate_view1,
	iterate_view2,
	iterate_view3,
	iterate_view4,
	iterate_view5,
	iterate_view6,
	iterate_view7,
	iterate_view8,
}

iterate_view1 :: proc(
	view: ^View1($A),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	a_data := cast(^[dynamic]A)set_a.data
	for &a, i in a_data {
		entity := set_a.dense[i]
		call_back(call_back_context, Entity(entity), &a)
	}
}

iterate_view2 :: proc(
	view: ^View2($A, $B),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A, b: ^B),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b)
		}
	}
}

iterate_view3 :: proc(
	view: ^View3($A, $B, $C),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A, b: ^B, c: ^C),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)
	set_c := _get_component_set_by_typeid(view.registry, C)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}
	if len(set_c.dense) < smallest_len {
		smallest = 2
		smallest_len = len(set_c.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b, c)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b, c)
		}
	case 2:
		c_data := cast(^[dynamic]C)set_c.data
		for &c, i in c_data {
			entity := set_c.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, &c)
		}
	}
}

iterate_view4 :: proc(
	view: ^View4($A, $B, $C, $D),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A, b: ^B, c: ^C, d: ^D),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)
	set_c := _get_component_set_by_typeid(view.registry, C)
	set_d := _get_component_set_by_typeid(view.registry, D)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}
	if len(set_c.dense) < smallest_len {
		smallest = 2
		smallest_len = len(set_c.dense)
	}
	if len(set_d.dense) < smallest_len {
		smallest = 3
		smallest_len = len(set_d.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b, c, d)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b, c, d)
		}
	case 2:
		c_data := cast(^[dynamic]C)set_c.data
		for &c, i in c_data {
			entity := set_c.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, &c, d)
		}
	case 3:
		d_data := cast(^[dynamic]D)set_d.data
		for &d, i in d_data {
			entity := set_d.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, &d)
		}
	}
}

iterate_view5 :: proc(
	view: ^View5($A, $B, $C, $D, $E),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A, b: ^B, c: ^C, d: ^D, e: ^E),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)
	set_c := _get_component_set_by_typeid(view.registry, C)
	set_d := _get_component_set_by_typeid(view.registry, D)
	set_e := _get_component_set_by_typeid(view.registry, E)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}
	if len(set_c.dense) < smallest_len {
		smallest = 2
		smallest_len = len(set_c.dense)
	}
	if len(set_d.dense) < smallest_len {
		smallest = 3
		smallest_len = len(set_d.dense)
	}
	if len(set_e.dense) < smallest_len {
		smallest = 4
		smallest_len = len(set_e.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b, c, d, e)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b, c, d, e)
		}
	case 2:
		c_data := cast(^[dynamic]C)set_c.data
		for &c, i in c_data {
			entity := set_c.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, &c, d, e)
		}
	case 3:
		d_data := cast(^[dynamic]D)set_d.data
		for &d, i in d_data {
			entity := set_d.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, &d, e)
		}
	case 4:
		e_data := cast(^[dynamic]E)set_e.data
		for &e, i in e_data {
			entity := set_e.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, &e)
		}
	}
}

iterate_view6 :: proc(
	view: ^View6($A, $B, $C, $D, $E, $F),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A, b: ^B, c: ^C, d: ^D, e: ^E, f: ^F),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)
	set_c := _get_component_set_by_typeid(view.registry, C)
	set_d := _get_component_set_by_typeid(view.registry, D)
	set_e := _get_component_set_by_typeid(view.registry, E)
	set_f := _get_component_set_by_typeid(view.registry, F)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}
	if len(set_c.dense) < smallest_len {
		smallest = 2
		smallest_len = len(set_c.dense)
	}
	if len(set_d.dense) < smallest_len {
		smallest = 3
		smallest_len = len(set_d.dense)
	}
	if len(set_e.dense) < smallest_len {
		smallest = 4
		smallest_len = len(set_e.dense)
	}
	if len(set_f.dense) < smallest_len {
		smallest = 5
		smallest_len = len(set_f.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b, c, d, e, f)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b, c, d, e, f)
		}
	case 2:
		c_data := cast(^[dynamic]C)set_c.data
		for &c, i in c_data {
			entity := set_c.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, &c, d, e, f)
		}
	case 3:
		d_data := cast(^[dynamic]D)set_d.data
		for &d, i in d_data {
			entity := set_d.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, &d, e, f)
		}
	case 4:
		e_data := cast(^[dynamic]E)set_e.data
		for &e, i in e_data {
			entity := set_e.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, &e, f)
		}
	case 5:
		f_data := cast(^[dynamic]F)set_f.data
		for &f, i in f_data {
			entity := set_f.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, e, &f)
		}
	}
}

iterate_view7 :: proc(
	view: ^View7($A, $B, $C, $D, $E, $F, $G),
	call_back_context: $T,
	call_back: proc(ctx: T, entity: Entity, a: ^A, b: ^B, c: ^C, d: ^D, e: ^E, f: ^F, g: ^G),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)
	set_c := _get_component_set_by_typeid(view.registry, C)
	set_d := _get_component_set_by_typeid(view.registry, D)
	set_e := _get_component_set_by_typeid(view.registry, E)
	set_f := _get_component_set_by_typeid(view.registry, F)
	set_g := _get_component_set_by_typeid(view.registry, G)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}
	if len(set_c.dense) < smallest_len {
		smallest = 2
		smallest_len = len(set_c.dense)
	}
	if len(set_d.dense) < smallest_len {
		smallest = 3
		smallest_len = len(set_d.dense)
	}
	if len(set_e.dense) < smallest_len {
		smallest = 4
		smallest_len = len(set_e.dense)
	}
	if len(set_f.dense) < smallest_len {
		smallest = 5
		smallest_len = len(set_f.dense)
	}
	if len(set_g.dense) < smallest_len {
		smallest = 6
		smallest_len = len(set_g.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b, c, d, e, f, g)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b, c, d, e, f, g)
		}
	case 2:
		c_data := cast(^[dynamic]C)set_c.data
		for &c, i in c_data {
			entity := set_c.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, &c, d, e, f, g)
		}
	case 3:
		d_data := cast(^[dynamic]D)set_d.data
		for &d, i in d_data {
			entity := set_d.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, &d, e, f, g)
		}
	case 4:
		e_data := cast(^[dynamic]E)set_e.data
		for &e, i in e_data {
			entity := set_e.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, &e, f, g)
		}
	case 5:
		f_data := cast(^[dynamic]F)set_f.data
		for &f, i in f_data {
			entity := set_f.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, e, &f, g)
		}
	case 6:
		g_data := cast(^[dynamic]G)set_g.data
		for &g, i in g_data {
			entity := set_g.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, e, f, &g)
		}
	}
}

iterate_view8 :: proc(
	view: ^View8($A, $B, $C, $D, $E, $F, $G, $H),
	call_back_context: $T,
	call_back: proc(
		ctx: T,
		entity: Entity,
		a: ^A,
		b: ^B,
		c: ^C,
		d: ^D,
		e: ^E,
		f: ^F,
		g: ^G,
		h: ^H,
	),
) {
	set_a := _get_component_set_by_typeid(view.registry, A)
	set_b := _get_component_set_by_typeid(view.registry, B)
	set_c := _get_component_set_by_typeid(view.registry, C)
	set_d := _get_component_set_by_typeid(view.registry, D)
	set_e := _get_component_set_by_typeid(view.registry, E)
	set_f := _get_component_set_by_typeid(view.registry, F)
	set_g := _get_component_set_by_typeid(view.registry, G)
	set_h := _get_component_set_by_typeid(view.registry, H)

	// pick whichever component set is smallest to minimize probes
	smallest := 0
	smallest_len := len(set_a.dense)
	if len(set_b.dense) < smallest_len {
		smallest = 1
		smallest_len = len(set_b.dense)
	}
	if len(set_c.dense) < smallest_len {
		smallest = 2
		smallest_len = len(set_c.dense)
	}
	if len(set_d.dense) < smallest_len {
		smallest = 3
		smallest_len = len(set_d.dense)
	}
	if len(set_e.dense) < smallest_len {
		smallest = 4
		smallest_len = len(set_e.dense)
	}
	if len(set_f.dense) < smallest_len {
		smallest = 5
		smallest_len = len(set_f.dense)
	}
	if len(set_g.dense) < smallest_len {
		smallest = 6
		smallest_len = len(set_g.dense)
	}
	if len(set_h.dense) < smallest_len {
		smallest = 7
		smallest_len = len(set_h.dense)
	}

	switch smallest {
	case 0:
		a_data := cast(^[dynamic]A)set_a.data
		for &a, i in a_data {
			entity := set_a.dense[i]
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), &a, b, c, d, e, f, g, h)
		}
	case 1:
		b_data := cast(^[dynamic]B)set_b.data
		for &b, i in b_data {
			entity := set_b.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), a, &b, c, d, e, f, g, h)
		}
	case 2:
		c_data := cast(^[dynamic]C)set_c.data
		for &c, i in c_data {
			entity := set_c.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, &c, d, e, f, g, h)
		}
	case 3:
		d_data := cast(^[dynamic]D)set_d.data
		for &d, i in d_data {
			entity := set_d.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, &d, e, f, g, h)
		}
	case 4:
		e_data := cast(^[dynamic]E)set_e.data
		for &e, i in e_data {
			entity := set_e.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, &e, f, g, h)
		}
	case 5:
		f_data := cast(^[dynamic]F)set_f.data
		for &f, i in f_data {
			entity := set_f.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, e, &f, g, h)
		}
	case 6:
		g_data := cast(^[dynamic]G)set_g.data
		for &g, i in g_data {
			entity := set_g.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			h, ok_h := sparse_set_try_get(set_h, entity, H)
			if !ok_h {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, e, f, &g, h)
		}
	case 7:
		h_data := cast(^[dynamic]H)set_h.data
		for &h, i in h_data {
			entity := set_h.dense[i]
			a, ok_a := sparse_set_try_get(set_a, entity, A)
			if !ok_a {
				continue
			}
			b, ok_b := sparse_set_try_get(set_b, entity, B)
			if !ok_b {
				continue
			}
			c, ok_c := sparse_set_try_get(set_c, entity, C)
			if !ok_c {
				continue
			}
			d, ok_d := sparse_set_try_get(set_d, entity, D)
			if !ok_d {
				continue
			}
			e, ok_e := sparse_set_try_get(set_e, entity, E)
			if !ok_e {
				continue
			}
			f, ok_f := sparse_set_try_get(set_f, entity, F)
			if !ok_f {
				continue
			}
			g, ok_g := sparse_set_try_get(set_g, entity, G)
			if !ok_g {
				continue
			}
			call_back(call_back_context, Entity(entity), a, b, c, d, e, f, g, &h)
		}
	}
}
