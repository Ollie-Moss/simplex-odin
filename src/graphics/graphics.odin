package graphics

import gl "vendor:OpenGL"
import "vendor:glfw"

init :: proc() {
	set_proc_address :: proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(name))
	}
	gl.load_up_to(4, 6, set_proc_address)

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
}
