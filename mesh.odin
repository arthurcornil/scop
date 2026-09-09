package main

import gl "vendor:OpenGL"

VAO :: u32
VBO :: u32
EBO :: u32

vertices := [?]f32{
    // positions         // colors
     0.5, -0.5, 0.0,  1.0, 0.0, 0.0,   // bottom right
    -0.5, -0.5, 0.0,  0.0, 1.0, 0.0,   // bottom let
     0.0,  0.5, 0.0,  0.0, 0.0, 1.0    // top 
}


get_vao :: proc() -> VAO {
	vao: VAO
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	vbo: VBO
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(0)
	gl.EnableVertexAttribArray(1)

	return vao
}
