package mesh

import gl "vendor:OpenGL"

Mesh :: struct {
	vertices: [dynamic]f32,
	faces: [dynamic]u32,
	vao: u32
}

get_vao :: proc(mesh: ^Mesh) -> u32 {
	vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	vbo: u32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(f32) * len(mesh.vertices),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW
	)

	ebo: u32
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		size_of(u32) * len(mesh.faces),
		raw_data(mesh.faces),
		gl.STATIC_DRAW
	)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	return vao
}
