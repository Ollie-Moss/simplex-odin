package graphics

import "../vmath/"
import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

Rect_Command :: struct {
	transform: vmath.Transform,
}

RenderCommand :: union {
	Rect_Command,
}

data_buffer := [dynamic]QuadVertex2D{}
graphis__quad_batch_mesh: Instanced_Mesh

shader: u32

init :: proc() {
	set_proc_address :: proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(name))
	}
	gl.load_up_to(3, 3, set_proc_address)

	// load shaders
	program, shader_success := gl.load_shaders(
		"src/shaders/sprite.vert",
		"src/shaders/sprite.frag",
	)
	shader = program
	if !shader_success {
		compile_err, type, link_err, linkTpye := gl.get_last_error_messages()
		fmt.printf("COMPILE ERROR: \n", compile_err, "\nLINKING ERROR: \n", link_err)
		panic("Failed to compile shaders")
	}

	graphis__quad_batch_mesh = create_instance_quad_mesh()
}

clear_color :: proc(color: vmath.vec4) {
	gl.ClearColor(color.r, color.g, color.b, color.w)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

sumbit_command :: proc {
	submit_rect_command,
}

submit_rect_command :: proc(cmd: Rect_Command) {
	vertex := QuadVertex2D {
		position         = cmd.transform.position.xy,
		size             = cmd.transform.size.xy,
		color            = vmath.vec4{0.0, 1.0, 1.0, 1.0},
		texture_position = cmd.transform.position.xy,
		texture_size     = cmd.transform.size.xy,
	}
	append(&data_buffer, vertex)
}


draw_all :: proc() {
	gl.UseProgram(shader)
	update_instance_data(&graphis__quad_batch_mesh, data_buffer[:])
	draw_instanced(&graphis__quad_batch_mesh, 1)
}
