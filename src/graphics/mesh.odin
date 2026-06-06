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
	using mesh:   Mesh,
	instance_vbo: VBO, // dynamic, rewritten each frame
}

update_data :: proc(mesh: ^Mesh, data: []$T) {
	fill_vbo(mesh.vbo, data)
}

update_instance_data :: proc(mesh: ^Instanced_Mesh, data: []$T) {
	fill_vbo(mesh.instance_vbo, data)
}

create_instance_quad_mesh :: proc() -> Instanced_Mesh {
	mesh := create_quad_mesh()
	instance_vbo := create_vbo()

	bind_vbo(mesh.vao, instance_vbo, layout_quad2d)

	return Instanced_Mesh{mesh = mesh, instance_vbo = instance_vbo}

}

create_quad_mesh :: proc() -> Mesh {
	vertices: []Vertex2D = {
		{position = {0, 0}},
		{position = {0, 1}},
		{position = {1, 1}},
		{position = {1, 0}},
	}

	indices: []u32 = {0, 1, 2, 0, 3, 2}

	return create_mesh(vertices, indices, gl.TRIANGLES, 6, layout_vertex2d)
}

create_mesh :: proc(
	vertices: []$TVertex,
	indices: []$TIndex,
	primitive: u32,
	vertex_count: i32,
	layout: VertexLayout,
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
		vertex_count = vertex_count,
	}
}

draw :: proc(mesh: ^Mesh) {
	gl.BindVertexArray(mesh.vao)
	gl.DrawElements(mesh.primitive, mesh.vertex_count, gl.UNSIGNED_INT, nil)
	gl.BindVertexArray(0)
}

draw_instanced :: proc(mesh: ^Instanced_Mesh, count: i32) {
	gl.BindVertexArray(mesh.vao)
	gl.DrawElementsInstanced(mesh.primitive, mesh.vertex_count, gl.UNSIGNED_INT, nil, count)
	gl.BindVertexArray(0)
}
