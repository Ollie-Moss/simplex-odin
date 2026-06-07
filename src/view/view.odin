package view

import "../input"
import "../vmath"
import "base:runtime"
import "core:fmt"
import "core:strings"
import "vendor:OpenGL"
import "vendor:glfw"

error_callback :: proc "c" (code: i32, desc: cstring) {
	context = runtime.default_context()
	fmt.println(desc, code)
}

view__window_size: vmath.ivec2

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	view__window_size = {width, height}
	OpenGL.Viewport(0, 0, width, height)
}

Window :: struct {
	windowHandle: glfw.WindowHandle,
}

Window_Options :: struct {
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

create_window :: proc(options: Window_Options) -> Window {
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
	glfw.SetFramebufferSizeCallback(windowHandle, framebuffer_size_callback)

	view__window_size = {options.windowSize.x, options.windowSize.y}
	return Window{windowHandle = windowHandle}
}

close_window :: proc(window: Window) {
	glfw.DestroyWindow(window.windowHandle)
	glfw.Terminate()
}
