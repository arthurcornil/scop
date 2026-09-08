package main

import "core:fmt"
import "core:os"
import "core:strings"

import "vendor:glfw"
import gl "vendor:OpenGL"

vertices := [?]f32{
    -0.5, -0.5, 0.0,
     0.5, -0.5, 0.0,
     0.0,  0.5, 0.0
}

VAO :: u32
VBO :: u32
Shader_Program :: u32

render :: proc(window: glfw.WindowHandle, vao: VAO) {
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	gl.BindVertexArray(vao)
	defer gl.BindVertexArray(0)
	gl.DrawArrays(gl.TRIANGLES, 0, 3)

	glfw.SwapBuffers(window)
}

main :: proc() {
	window, err := init_window()
	if err != nil do fatal(err)
	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)

	//set vao and vbo
	vao: VAO
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	vbo: VBO
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	//describe gpu buffer data
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
	//describe vertex attributes
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	//shaders
	vertex_shader := string(#load("vertex.glsl"))
	fragment_shader := string(#load("fragment.glsl"))

	shader_program, ok := gl.load_shaders_source(vertex_shader, fragment_shader)
	if !ok {
		//TODO: handle error properly once in other function
		os.exit(1)
	}

	gl.UseProgram(shader_program)

	for !glfw.WindowShouldClose(window) {
		process_input(window)
		glfw.PollEvents()

		render(window, vao)
	}
}
