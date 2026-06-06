package assets

import "core:fmt"
import gl "vendor:OpenGL"

Shader :: distinct u32

Shader_Handle :: Asset_Handle

Shader_Config :: struct {
	vertexPath:   string,
	fragmentPath: string,
}

load_shader :: proc(registry: ^Asset_Registry, config: Shader_Config) -> Shader_Handle {
	register_asset_list(registry, Shader, delete_shader)

	program, shader_success := gl.load_shaders(config.vertexPath, config.fragmentPath)
	if !shader_success {
		compile_err, type, link_err, linkTpye := gl.get_last_error_messages()
		fmt.printf("COMPILE ERROR: \n", compile_err, "\nLINKING ERROR: \n", link_err)
		panic("Failed to compile shaders")
	}

	shader: Shader = Shader(program)


	return insert_asset(registry, shader)
}

delete_shader :: proc(data: rawptr) {
	shader := cast(^Shader)data
	gl.DeleteProgram(u32(shader^))
}
