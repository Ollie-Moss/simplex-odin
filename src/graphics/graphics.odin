package graphics

import gl "vendor:OpenGL"
import "vendor:glfw"

init :: proc() {
	set_proc_address :: proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(name))
	}
	gl.load_up_to(3, 3, set_proc_address)
}
