package renderer

import gl "vendor:OpenGL"

import "../mesh"

GPU_Mesh :: struct {
	vao, vbo, ebo: u32,
	count_indices: i32
}

upload :: proc(m: ^mesh.Mesh) -> (g: GPU_Mesh) {
	gl.GenVertexArrays(1, &g.vao)
	gl.BindVertexArray(g.vao)

	gl.GenBuffers(1, &g.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, g.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(mesh.Vertex) * len(m.vertices),
		raw_data(m.vertices),
		gl.STATIC_DRAW
	)

	gl.GenBuffers(1, &g.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, g.ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		size_of(u32) * len(m.indices),
		raw_data(m.indices),
		gl.STATIC_DRAW
	)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(mesh.Vertex), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(mesh.Vertex), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(mesh.Vertex), 6 * size_of(f32))
	gl.EnableVertexAttribArray(2)
	gl.BindVertexArray(0)
	g.count_indices = i32(len(m.indices))
	return
}

gpu_mesh_destroy :: proc(g: ^GPU_Mesh) {
	if g.vbo != 0 do gl.DeleteBuffers(1, &g.vbo)
	if g.vao != 0 do gl.DeleteVertexArrays(1, &g.vao)
	if g.ebo != 0 do gl.DeleteBuffers(1, &g.ebo)
	g^ = {}
}
