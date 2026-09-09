package main

import "core:math"

import "vendor:glfw"
import gl "vendor:OpenGL"

render :: proc(window: glfw.WindowHandle, vao: VAO, program: Shader_Program) {
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	time_value := glfw.GetTime()
	green_value: f32 = math.sin(f32(time_value)) / 2.0 + 0.5
	vertex_color_location := gl.GetUniformLocation(program, "ourColor")
	gl.Uniform4f(vertex_color_location, 0.0, green_value, 0.3, 1.0)

	gl.BindVertexArray(vao)
	defer gl.BindVertexArray(0)
	gl.DrawArrays(gl.TRIANGLES, 0, 3)

	glfw.SwapBuffers(window)
}

main :: proc() {
	err: Error
	window: glfw.WindowHandle

	window, err = init_window()
	if err != nil do fatal(err)
	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)

	triangle: VAO = get_vao()

	shader_program: Shader_Program
	shader_program, err = get_shader_program()
	if err != nil {
		fatal(err)
	}

	gl.UseProgram(shader_program)

	for !glfw.WindowShouldClose(window) {
		process_input(window)
		glfw.PollEvents()

		render(window, triangle, shader_program)
	}
}
