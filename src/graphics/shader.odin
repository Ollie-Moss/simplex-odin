package graphics

import "simplex:assets"
import "core:fmt"
import gl "vendor:OpenGL"

Shader :: distinct u32

Shader_Handle :: assets.Asset_Handle

Shader_Config :: struct {
	vertexPath:   string,
	fragmentPath: string,
}

load_shader :: proc(registry: ^assets.Asset_Registry, config: Shader_Config) -> Shader_Handle {
	assets.register_asset_list(registry, Shader, delete_shader)

	program, shader_success := gl.load_shaders(config.vertexPath, config.fragmentPath)
	if !shader_success {
		compile_err, type, link_err, linkTpye := gl.get_last_error_messages()
		fmt.printf("COMPILE ERROR: \n", compile_err, "\nLINKING ERROR: \n", link_err)
		panic("Failed to compile shaders")
	}

	shader: Shader = Shader(program)


	return assets.insert_asset(registry, shader)
}

delete_shader :: proc(data: rawptr) {
	shader := cast(^Shader)data
	gl.DeleteProgram(u32(shader^))
}

use_shader :: proc(shader: Shader) {
	gl.UseProgram(u32(shader))
}

shader_set_bool :: proc(shader: Shader, name: cstring, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(u32(shader), name), i32(value))
}

shader_set_int :: proc(shader: Shader, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(u32(shader), name), value)
}

shader_set_float :: proc(shader: Shader, name: cstring, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(u32(shader), name), value)
}

shader_set_vec2 :: proc(shader: Shader, name: cstring, value: ^[2]f32) {
	gl.Uniform2fv(gl.GetUniformLocation(u32(shader), name), 1, &value[0])
}

shader_set_vec3 :: proc(shader: Shader, name: cstring, value: ^[3]f32) {
	gl.Uniform3fv(gl.GetUniformLocation(u32(shader), name), 1, &value[0])
}

shader_set_vec4 :: proc(shader: Shader, name: cstring, value: ^[4]f32) {
	gl.Uniform4fv(gl.GetUniformLocation(u32(shader), name), 1, &value[0])
}

shader_set_mat4 :: proc(shader: Shader, name: cstring, value: ^matrix[4, 4]f32) {
	gl.UniformMatrix4fv(gl.GetUniformLocation(u32(shader), name), 1, false, &value[0, 0])
}
