package main

import "core:fmt"
import "core:os"
import "vendor:glfw"
import gl "vendor:OpenGL"

GL_MAJOR :: 3
GL_MINOR :: 3

GLFW_Error :: enum {
	None = 0,
	Init_Error,
	Window_Error
}

fatal :: proc(msg: string) {
	fmt.eprintf("Error: %s\n", msg)
	os.exit(1)
}

init_window :: proc() -> (window: glfw.WindowHandle, err: GLFW_Error) {
	if !glfw.Init() do return nil, .Init_Error

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, true)

	window = glfw.CreateWindow(800, 600, "scop", nil, nil)
	if window == nil do return nil, .Window_Error
	
	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1)
	gl.load_up_to(GL_MAJOR, GL_MINOR, glfw.gl_set_proc_address)

	return
}

main :: proc() {
	window, ok := init_window()
	#partial switch ok {
	case .Init_Error:
		fatal("failed to init glfw")
	case .Window_Error:
		fatal("failed to open window")
	}
	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)

	for !glfw.WindowShouldClose(window) {
		glfw.SwapBuffers(window)
		glfw.PollEvents()
		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	}
}
