package main

import "core:fmt"
import "core:math"
import "core:math/linalg"

import "vendor:glfw"
import gl "vendor:OpenGL"

render :: proc(window: glfw.WindowHandle, vao: VAO, program: Shader_Program) {
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	gl.UseProgram(program)

	model := linalg.matrix4_rotate(
		f32(linalg.to_radians(-55.0)),
		[?]f32{1.0, 0.5, 0.5}
	)
	view := linalg.matrix4_translate(
		[?]f32{0.0, 0.0, -3.0}
	)
	projection := linalg.matrix4_perspective(
		f32(linalg.to_radians(45.0)),
		800.0 / 600.0,
		0.1,
		100.0
	)

	modelLoc := gl.GetUniformLocation(program, "model")
	gl.UniformMatrix4fv(modelLoc, 1, gl.FALSE, &model[0][0])
	viewLoc := gl.GetUniformLocation(program, "view")
	gl.UniformMatrix4fv(viewLoc, 1, gl.FALSE, &view[0][0])
	projectionLoc := gl.GetUniformLocation(program, "projection")
	gl.UniformMatrix4fv(projectionLoc, 1, gl.FALSE, &projection[0][0])

	gl.BindVertexArray(vao)
	defer gl.BindVertexArray(0)
	gl.DrawArrays(gl.TRIANGLES, 0, 36)

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

	for !glfw.WindowShouldClose(window) {
		process_input(window)
		glfw.PollEvents()

		render(window, triangle, shader_program)
	}
}
