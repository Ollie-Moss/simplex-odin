package view

import "../input"
import "../vmath"
import "base:runtime"
import "core:fmt"
import "core:strings"
import "vendor:glfw"

error_callback :: proc "c" (code: i32, desc: cstring) {
	context = runtime.default_context()
	fmt.println(desc, code)
}

Window :: struct {
	windowHandle: glfw.WindowHandle,
}

WindowOptions :: struct {
	windowSize: vmath.ivec2,
	title:      string,
}

update :: proc(window: Window) {
	glfw.SwapBuffers(window.windowHandle)
}

should_quit :: proc(window: Window) -> bool {
	return bool(glfw.WindowShouldClose(window.windowHandle))
}

init :: proc() {
	glfw.SetErrorCallback(error_callback)

	if !glfw.Init() {
		panic("EXIT_FAILURE")
	}

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 2)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 0)
}

create_window :: proc(options: WindowOptions) -> Window {
	windowHandle := glfw.CreateWindow(
		options.windowSize.x,
		options.windowSize.y,
		strings.clone_to_cstring(options.title),
		nil,
		nil,
	)

	if windowHandle == nil {
		panic("EXIT_FAILURE")
	}

	glfw.SetKeyCallback(windowHandle, input.key_callback)

	glfw.MakeContextCurrent(windowHandle)

	return Window{windowHandle = windowHandle}
}

close_window :: proc(window: Window) {
	glfw.DestroyWindow(window.windowHandle)
	glfw.Terminate()
}
