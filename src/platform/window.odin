package platform

import "vendor:glfw"
import gl "vendor:OpenGL"

import "../errors"

Window :: glfw.WindowHandle
GL_MAJOR :: 3
GL_MINOR :: 3
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

init_window :: proc() -> (window: Window, err: errors.GLFW_Error) {
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
	gl.Enable(gl.DEPTH_TEST)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	return
}

process_input :: proc(window: Window) {
	glfw.PollEvents()
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

should_close :: proc(win: Window) -> bool { return bool(glfw.WindowShouldClose(win)) }

swap_buffers :: proc(win: Window) { glfw.SwapBuffers(win) }

destroy :: proc(win: Window) {
	glfw.DestroyWindow(win)
	glfw.Terminate()
}

aspect :: proc(win: Window) -> f32 {
	w, h := glfw.GetFramebufferSize(win)
	return h == 0 ? 1 : f32(w) / f32(h)
}

time :: proc() -> f64 { return glfw.GetTime() }
