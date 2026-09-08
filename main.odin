package main

import "core:fmt"
import "core:os"

import "vendor:glfw"
import gl "vendor:OpenGL"

fatal :: proc(msg: string) {
	fmt.eprintf("Error: %s\n", msg)
	os.exit(1)
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
		process_input(window)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}
