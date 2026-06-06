package graphics

import "../vmath"
import gl "vendor:OpenGL"

VAO :: u32
VBO :: u32
EBO :: u32

Attribute_Type :: enum u32 {
	Float = gl.FLOAT,
	Int   = gl.INT,
	Byte  = gl.BYTE,
}

AttributeDesc :: struct {
	location:             u32,
	property_vector_size: i32, // This is 1, 2, 3, or 4. Represents the amount of components in the vector
	type:                 Attribute_Type,
	offset:               uintptr,
	divsor:               u32,
}

VertexLayout :: struct {
	attributes: []AttributeDesc,
	stride:     i32,
}

Vertex2D :: struct {
	position: vmath.vec2,
}

QuadVertex2D :: struct {
	position:         vmath.vec2,
	size:             vmath.vec2,
	color:            vmath.vec4,
	texture_position: vmath.vec2,
	texture_size:     vmath.vec2,
}

layout_vertex2d := VertexLayout {
	stride     = size_of(Vertex2D),
	attributes = {
		{
			location = 0,
			property_vector_size = 2,
			type = .Float,
			offset = offset_of(Vertex2D, position),
			divsor = 0,
		},
	},
}

layout_quad2d := VertexLayout {
	stride     = size_of(QuadVertex2D),
	attributes = {
		{
			location = 1,
			property_vector_size = 2,
			type = .Float,
			offset = offset_of(QuadVertex2D, position),
			divsor = 1,
		},
		{
			location = 2,
			property_vector_size = 2,
			type = .Float,
			offset = offset_of(QuadVertex2D, size),
			divsor = 1,
		},
		{
			location = 3,
			property_vector_size = 4,
			type = .Float,
			offset = offset_of(QuadVertex2D, color),
			divsor = 1,
		},
		{
			location = 4,
			property_vector_size = 2,
			type = .Float,
			offset = offset_of(QuadVertex2D, texture_position),
			divsor = 1,
		},
		{
			location = 5,
			property_vector_size = 2,
			type = .Float,
			offset = offset_of(QuadVertex2D, texture_size),
			divsor = 1,
		},
	},
}

create_vao :: proc() -> VAO {
	vao: VAO
	gl.GenVertexArrays(1, &vao)
	return vao
}

bind_vbo :: proc(vao: VAO, vbo: VBO, layout: VertexLayout) {
	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	for attribute in layout.attributes {
		gl.EnableVertexAttribArray(attribute.location)
		gl.VertexAttribPointer(
			attribute.location,
			attribute.property_vector_size,
			u32(attribute.type),
			gl.FALSE,
			layout.stride,
			attribute.offset,
		)
		gl.VertexAttribDivisor(attribute.location, attribute.divsor)
	}
}

bind_ebo :: proc(vao: VAO, ebo: EBO) {
	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BindVertexArray(0)
}

create_vbo :: proc() -> VBO {
	vbo: VBO
	gl.GenBuffers(1, &vbo)
	return vbo
}

fill_vbo :: proc(vbo: VBO, data: []$T) {
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(data) * size_of(T), raw_data(data), gl.DYNAMIC_DRAW)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}

create_ebo :: proc() -> EBO {
	ebo: EBO
	gl.GenBuffers(1, &ebo)
	return ebo
}

fill_ebo :: proc(ebo: EBO, indices: []$T) {
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)

	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(T),
		raw_data(indices),
		gl.DYNAMIC_DRAW,
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

destroy_vao :: proc(vao: ^VAO) {
	gl.DeleteVertexArrays(1, vao)
}

destroy_vbo :: proc(vbo: ^VBO) {
	gl.DeleteBuffers(1, vbo)
}


destroy_ebo :: proc(ebo: ^EBO) {
	gl.DeleteBuffers(1, ebo)
}
