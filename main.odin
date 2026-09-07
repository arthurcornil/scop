package main

import "core:fmt"
import "core:os"
import "vendor:glfw"
import gl "vendor:OpenGL"

GL_MAJOR :: 3
GL_MINOR :: 3

main :: proc() {
	if !glfw.Init() {
		fmt.eprintln("failed to init glfw")	
		os.exit(1)
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, true)

	window := glfw.CreateWindow(800, 600, "scop", nil, nil)
	if window == nil {
		fmt.eprintln("failed to create window")
		os.exit(1)
	}
	defer glfw.DestroyWindow(window)
	
	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1)
	gl.load_up_to(GL_MAJOR, GL_MINOR, glfw.gl_set_proc_address)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()
		gl.ClearColor(0, 0, 0, 0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		glfw.SwapBuffers(window)
	}
}
