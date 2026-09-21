package mesh

Mesh :: struct {
	vertices: [dynamic]f32,
	indices: [dynamic]u32,
}

destroy :: proc(m: ^Mesh) {
	delete(m.vertices)
	delete(m.indices)
	m^ = {}
}
