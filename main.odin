package main

import "core:fmt"
import "core:os"
import "./parser"
import "./mesh"
import "./errors"
import "core:math"
import "core:math/linalg"

import "vendor:glfw"
import gl "vendor:OpenGL"

Window :: glfw.WindowHandle

render :: proc(window: Window, m: mesh.Mesh, program: u32) {
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	gl.UseProgram(program)

	model := linalg.matrix4_rotate(
		12,
		[?]f32{0.0, 1.0, 0.0}
	)

	radius: f32 : 10.0
	camX: f32 = f32(math.sin(1.0)) * radius
	camZ: f32 = f32(math.cos(1.0)) * radius
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

	gl.BindVertexArray(m.vao)
	defer gl.BindVertexArray(0)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(m.vertices) / 3))

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

main :: proc() {
	if len(os.args) != 2 {
		fmt.eprintln("Usage: scop [PATH TO .obj FILE]")
		os.exit(1)
	}

	m := mesh.Mesh{}
	defer delete(m.vertices)

	//Init Mesh
	err := parser.parse(os.args[1], &m)
	if err != nil {
		errors.fatal(err)
	}

	//Init Window
	win: Window
	win, err = init_window()
	if err != nil {
		errors.fatal(err)
	}
	defer glfw.Terminate()
	defer glfw.DestroyWindow(win)

	m.vao = mesh.get_vao(&m)
	shader_program: u32
	shader_program, err = get_shader_program()
	if err != nil {
		errors.fatal(err)
	}

	for !glfw.WindowShouldClose(win) {
		process_input(win)
		glfw.PollEvents()

		render(win, m, shader_program)
	}
}
