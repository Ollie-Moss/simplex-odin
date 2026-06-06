package graphics

import "../assets"
import gl "vendor:OpenGL"

use_shader :: proc(shader: assets.Shader) {
	gl.UseProgram(u32(shader))
}

shader_set_bool :: proc(shader: assets.Shader, name: cstring, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(u32(shader), name), i32(value))
}

shader_set_int :: proc(shader: assets.Shader, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(u32(shader), name), value)
}

shader_set_float :: proc(shader: assets.Shader, name: cstring, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(u32(shader), name), value)
}

shader_set_vec2 :: proc(shader: assets.Shader, name: cstring, value: ^[2]f32) {
	gl.Uniform2fv(gl.GetUniformLocation(u32(shader), name), 1, &value[0])
}

shader_set_vec3 :: proc(shader: assets.Shader, name: cstring, value: ^[3]f32) {
	gl.Uniform3fv(gl.GetUniformLocation(u32(shader), name), 1, &value[0])
}

shader_set_vec4 :: proc(shader: assets.Shader, name: cstring, value: ^[4]f32) {
	gl.Uniform4fv(gl.GetUniformLocation(u32(shader), name), 1, &value[0])
}

shader_set_mat4 :: proc(shader: assets.Shader, name: cstring, value: ^matrix[4, 4]f32) {
	gl.UniformMatrix4fv(gl.GetUniformLocation(u32(shader), name), 1, false, &value[0, 0])
}
