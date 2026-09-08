package main

import "vendor:glfw"
import gl "vendor:OpenGL"

GL_MAJOR :: 3
GL_MINOR :: 3
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

init_window :: proc() -> (window: glfw.WindowHandle, err: GLFW_Error) {
	if !glfw.Init() do return nil, .Init_Error

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)

	window = glfw.CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "scop", nil, nil)
	if window == nil do return nil, .Window_Error
	
	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1)
	gl.load_up_to(GL_MAJOR, GL_MINOR, glfw.gl_set_proc_address)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	return
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}
