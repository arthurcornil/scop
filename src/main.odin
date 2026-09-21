package main

import "core:fmt"
import "core:os"
import "core:math"
import "core:math/linalg"

import "vendor:glfw"
import gl "vendor:OpenGL"

import "./parser"
import "./renderer"
import "./mesh"
import "./errors"

Window :: glfw.WindowHandle

render :: proc(window: Window, g: ^renderer.GPU_Mesh, program: u32) {
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	gl.UseProgram(program)

	model := linalg.matrix4_rotate(
		0.0,
		[?]f32{-0.5, 1.0, 0.5}
	)

	radius: f32 : 10.0
	camX: f32 = f32(math.sin(glfw.GetTime())) * radius
	camZ: f32 = f32(math.cos(glfw.GetTime())) * radius
	view := linalg.matrix4_look_at(
		[3]f32{camX, 0.0, camZ},
		[3]f32{0.0, 0.0, 0.0},
		[3]f32{0.0, 1.0, 0.0},
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

	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	gl.BindVertexArray(g.vao)
	defer gl.BindVertexArray(0)
	gl.DrawElements(gl.TRIANGLES, g.count_indices, gl.UNSIGNED_INT, nil)

	glfw.SwapBuffers(window)
}

get_shader_program :: proc() -> (sp: u32, err: errors.Error) {
	vertex_shader := string(#load("shaders/vertex.glsl"))
	fragment_shader := string(#load("shaders/fragment.glsl"))

	ok: bool
	sp, ok = gl.load_shaders_source(vertex_shader, fragment_shader)
	if !ok {
		return 0, .Compilation_Error
	}
	return
}

run :: proc(path: string) -> (err: errors.Error) {
	win := init_window() or_return
	defer glfw.Terminate()
	defer glfw.DestroyWindow(win)

	m := mesh.Mesh{}
	defer mesh.destroy(&m)
	parser.parse(path, &m) or_return

	gpu_data := renderer.upload(&m)
	defer renderer.destroy(&gpu_data)
	mesh.destroy(&m)

	shader_program := get_shader_program() or_return

	for !glfw.WindowShouldClose(win) {
		process_input(win)
		glfw.PollEvents()
		render(win, &gpu_data, shader_program)
	}
	return nil
}

main :: proc() {
	if len(os.args) != 2 {
		fmt.eprintln("Usage: scop [PATH TO .obj FILE]")
		os.exit(1)
	}
	if err := run(os.args[1]); err != nil {
		errors.report(err)
		os.exit(1)
	}
}
