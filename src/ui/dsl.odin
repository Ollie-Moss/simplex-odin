package ui

import "core:fmt"
import "core:hash/xxhash"
import "core:mem"
import "simplex:vmath"

hex :: proc(hex: i32) -> vmath.vec4 {
	return {f32(hex | 0xFF0000), f32(hex | 0x00FF00), f32(hex | 0x0000FF), 255}
}

pixels :: proc(amount: f32) -> Length {
	return {.Pixels, amount}
}

percent :: proc(amount: f32) -> Length {
	return {.Percent, amount}
}

Child :: union {
	Element,
	[]Element,
}

kids :: proc(children: ..Child) -> [dynamic]Element {
	elements := make([dynamic]Element, context.temp_allocator)
	for &child, slot_index in children {
		switch &typed_child in child {
		case Element:
			typed_child.slot = slot_index
			append(&elements, typed_child)
		case []Element:
			for &elem, sub_index in typed_child {
				elem.slot = slot_index
				elem.sub = sub_index
				append(&elements, elem)
			}
		}
	}

	return elements
}

mix :: proc(a, b: u64) -> u64 {
	pair := [2]u64{a, b}
	bytes := mem.slice_to_bytes(pair[:])
	return xxhash.XXH3_64(bytes)
}

child_id :: proc(parent: ID, e: ^Element) -> ID {
	hash := mix(u64(parent), u64(e.slot))
	hash = mix(hash, e.key if e.has_key else u64(e.sub))
	return ID(hash)
}

keyed :: proc(key: u64, e: Element) -> Element {
	e := e; e.key, e.has_key = key, true
	return e
}

element :: proc(style: Style, children: ..Child) -> Element {
	return {style = style, children = kids(..children)}
}

column :: proc(style: Style, children: ..Child) -> Element {
	elem := Element {
		style    = style,
		children = kids(..children),
	}
	elem.style.layout_direction = .Vertical
	return elem
}

row :: proc(style: Style, children: ..Child) -> Element {
	elem := Element {
		style    = style,
		children = kids(..children),
	}
	elem.style.layout_direction = .Horizontal
	return elem
}

label :: proc(text: string, style: Style = {}, children: ..Child) -> Element {
	return {style = style, children = kids(..children)}
}

show :: proc(condition: bool, element: Element) -> Child {
	return element if condition else nil
}

test_ui :: proc() -> Element {
	return element(Default_Style, label("Hello, World!"))
}

reconcile :: proc(tree: ^Tree, element: Element) {
	if tree.root == nil {
		tree.root = create_node(tree, ROOT_ID, element)
		mark_dirty(tree, tree.root)
	} else {
		update_node(tree, tree.root, element)
	}
}

create_node :: proc(tree: ^Tree, id: ID, element: Element) -> ^Node {
	node := new(Node, tree.allocator)
	node.id = id
	node.style = element.style
	node.children = make([dynamic]^Node, tree.allocator)

	for &child_element in element.children {
		child_node := create_node(tree, child_id(node.id, &child_element), child_element)
		child_node.parent = node
		append(&node.children, child_node)
	}

	return node
}

update_node :: proc(tree: ^Tree, node: ^Node, element: Element) {
	if node.layout != element.style.layout {
		node.layout = element.style.layout
		mark_dirty(tree, node)
	}

	if node.paint != element.style.paint {
		node.paint = element.style.paint
	}

	old := make(map[ID]^Node, context.temp_allocator)

	for child in node.children {
		old[child.id] = child
	}

	next := make([dynamic]^Node, context.temp_allocator)
	structure_changed := len(element.children) != len(node.children)

	for &child, index in element.children {
		id := child_id(node.id, &child)

		child_node, found := old[id]
		if found {
			delete_key(&old, id)
			update_node(tree, child_node, child)
			append(&next, child_node)
		} else {
			created_node := create_node(tree, id, child)
			append(&next, created_node)
			structure_changed = true
		}
	}

	// delete
	for child in node.children {
		if child.id in old {delete_subtree(tree, child)}
	}

	if structure_changed {
		clear(&node.children)
		append(&node.children, ..next[:])
		mark_dirty(tree, node)
	}
}

layout_boundary :: proc(node: ^Node) -> bool {
	return node.parent == nil || (node.width_mode == .Fixed || node.height_mode == .Fixed)
}

speculative_boundary :: proc(node: ^Node) -> bool {
	return node.parent == nil || (node.width_mode == .Grow || node.height_mode == .Grow)
}

mark_dirty :: proc(tree: ^Tree, node: ^Node) {
	cur := node
	for !layout_boundary(cur) {cur = cur.parent}

	if .Layout_Root not_in cur.dirty {
		cur.dirty += {.Layout_Root}
		append(&tree.layout_roots, cur)
	}
}

delete_subtree :: proc(tree: ^Tree, node: ^Node) {
	for child in node.children {
		delete_subtree(tree, child)
	}
	delete(node.children)
	if node == nil do return
	free(node, tree.allocator)
}

make_tree :: proc(allocator := context.allocator) -> ^Tree {
	tree := new(Tree, allocator)
	if tree == nil do return nil

	tree.allocator = allocator
	tree.root = nil
	tree.layout_roots = make([dynamic]^Node, allocator)

	return tree
}

delete_tree :: proc(tree: ^Tree) {
	free_all(tree.allocator)
	free(tree)
}
