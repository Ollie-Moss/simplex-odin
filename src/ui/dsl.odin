package ui

import "core:hash/xxhash"
import "core:mem"

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
	for child in children {
		switch typed_child in child {
		case Element:
			append(&elements, typed_child)
		case []Element:
			for elem in typed_child {
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
	} else {
		update_node(tree, tree.root, element)
	}
}

create_node :: proc(tree: ^Tree, id: ID, element: Element) -> ^Node {
	node := new(Node, tree.allocator)
	node.style = element.style
	node.children = make([dynamic]^Node, tree.allocator)

	for &child_element, i in element.children {
		child_node := create_node(tree, child_id(id, &child_element), child_element)
		append(&node.children, child_node)
	}

	return node
}

update_node :: proc(tree: ^Tree, node: ^Node, element: Element) {
	if node.layout != element.style.layout {
		node.layout = element.style.layout
		// layout dirty
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

		if node.children[index].id != id {structure_changed = true}
	}

	// delete
	for child in node.children {
		if child.id in old {delete_subtree(tree, child)}
	}

	if structure_changed {
		clear(&node.children)
		append(&node.children, ..next[:])
		// this is dirty
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
	delete_subtree(tree, tree.root)
	delete(tree.layout_roots)
	free(tree)
}
