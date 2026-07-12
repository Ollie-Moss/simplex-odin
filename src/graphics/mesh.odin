package graphics

import gl "vendor:OpenGL"

Mesh :: struct {
	vao:          VAO,
	vbo:          VBO,
	ebo:          EBO,
	primitive:    u32,
	vertex_count: i32,
}

Instanced_Mesh :: struct {
	using mesh:     Mesh,
	instance_vbo:   VBO,
	instance_count: i32,
}

create_instanced_mesh :: proc(
	instanced_vertices: []$T,
	baseMesh: Mesh,
	layout: Vertex_Layout,
) -> Instanced_Mesh {
	instance_vbo := create_vbo()
	bind_vbo(baseMesh.vao, instance_vbo, layout)
	fill_vbo(instance_vbo, instanced_vertices)

	return Instanced_Mesh{mesh = baseMesh, instance_vbo = instance_vbo}
}

destroy_instanced_mesh :: proc(instanced_mesh: ^Instanced_Mesh) {
	destroy_mesh(&instanced_mesh.mesh)
	destroy_vbo(&instanced_mesh.vbo)
}

update_instance_data :: proc(mesh: ^Instanced_Mesh, data: []$T) {
	fill_vbo(mesh.instance_vbo, data)
	mesh.instance_count = i32(len(data))
}

draw_instanced :: proc(mesh: ^Instanced_Mesh) {
	gl.BindVertexArray(mesh.vao)
	gl.DrawElementsInstanced(
		mesh.primitive,
		mesh.vertex_count,
		gl.UNSIGNED_INT,
		nil,
		mesh.instance_count,
	)
	gl.BindVertexArray(0)
}

create_mesh :: proc(
	vertices: []$TVertex,
	indices: []$TIndex,
	primitive: u32,
	layout: Vertex_Layout,
) -> Mesh {
	vao := create_vao()

	vbo := create_vbo()
	bind_vbo(vao, vbo, layout)
	fill_vbo(vbo, vertices)

	ebo := create_ebo()
	bind_ebo(vao, ebo)
	fill_ebo(ebo, indices)

	return Mesh {
		vao = vao,
		vbo = vbo,
		ebo = ebo,
		primitive = primitive,
		vertex_count = i32(len(indices)),
	}
}

destroy_mesh :: proc(mesh: ^Mesh) {
	destroy_vao(&mesh.vao)
	destroy_vbo(&mesh.vbo)
	destroy_ebo(&mesh.ebo)
}

update_data :: proc(mesh: ^Mesh, vertices: []$TVertex, indices: []$TIndex) {
	fill_vbo(mesh.vbo, vertices)
	fill_ebo(mesh.ebo, indices)
	mesh.vertex_count = len(indices)
}

draw :: proc(mesh: ^Mesh) {
	gl.BindVertexArray(mesh.vao)
	gl.DrawElements(mesh.primitive, mesh.vertex_count, gl.UNSIGNED_INT, nil)
	gl.BindVertexArray(0)
}

create_quad_mesh :: proc() -> Mesh {
	vertices: []Vertex_2D = {
		{position = {0, 0}},
		{position = {0, 1}},
		{position = {1, 1}},
		{position = {1, 0}},
	}

	indices: []u32 = {0, 1, 2, 0, 3, 2}

	return create_mesh(vertices, indices, gl.TRIANGLES, layout_vertex_2d)
}

create_cube_mesh :: proc() -> Mesh {
	vertices: []Vertex_3D = {
		// Front (+Z)
		{{-0.5, -0.5, 0.5}, {0, 0, 1}, {0, 0}},
		{{0.5, -0.5, 0.5}, {0, 0, 1}, {1, 0}},
		{{0.5, 0.5, 0.5}, {0, 0, 1}, {1, 1}},
		{{-0.5, 0.5, 0.5}, {0, 0, 1}, {0, 1}},

		// Back (-Z)
		{{0.5, -0.5, -0.5}, {0, 0, -1}, {0, 0}},
		{{-0.5, -0.5, -0.5}, {0, 0, -1}, {1, 0}},
		{{-0.5, 0.5, -0.5}, {0, 0, -1}, {1, 1}},
		{{0.5, 0.5, -0.5}, {0, 0, -1}, {0, 1}},

		// Left (-X)
		{{-0.5, -0.5, -0.5}, {-1, 0, 0}, {0, 0}},
		{{-0.5, -0.5, 0.5}, {-1, 0, 0}, {1, 0}},
		{{-0.5, 0.5, 0.5}, {-1, 0, 0}, {1, 1}},
		{{-0.5, 0.5, -0.5}, {-1, 0, 0}, {0, 1}},

		// Right (+X)
		{{0.5, -0.5, 0.5}, {1, 0, 0}, {0, 0}},
		{{0.5, -0.5, -0.5}, {1, 0, 0}, {1, 0}},
		{{0.5, 0.5, -0.5}, {1, 0, 0}, {1, 1}},
		{{0.5, 0.5, 0.5}, {1, 0, 0}, {0, 1}},

		// Top (+Y)
		{{-0.5, 0.5, 0.5}, {0, 1, 0}, {0, 0}},
		{{0.5, 0.5, 0.5}, {0, 1, 0}, {1, 0}},
		{{0.5, 0.5, -0.5}, {0, 1, 0}, {1, 1}},
		{{-0.5, 0.5, -0.5}, {0, 1, 0}, {0, 1}},

		// Bottom (-Y)
		{{-0.5, -0.5, -0.5}, {0, -1, 0}, {0, 0}},
		{{0.5, -0.5, -0.5}, {0, -1, 0}, {1, 0}},
		{{0.5, -0.5, 0.5}, {0, -1, 0}, {1, 1}},
		{{-0.5, -0.5, 0.5}, {0, -1, 0}, {0, 1}},
	}

	indices: []u32 = {
		0,
		1,
		2,
		0,
		2,
		3, // Front
		4,
		5,
		6,
		4,
		6,
		7, // Back
		8,
		9,
		10,
		8,
		10,
		11, // Left
		12,
		13,
		14,
		12,
		14,
		15, // Right
		16,
		17,
		18,
		16,
		18,
		19, // Top
		20,
		21,
		22,
		20,
		22,
		23, // Bottom
	}

	return create_mesh(vertices, indices, gl.TRIANGLES, layout_vertex_3d)
}

create_instanced_quad_mesh :: proc() -> Instanced_Mesh {
	return create_instanced_mesh([]Quad_Vertex_2D{}, create_quad_mesh(), layout_instance_quad_2d)
}
