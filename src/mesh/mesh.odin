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

center :: proc(m: Mesh) -> (center_vec: [3]f32) {
	lowest := [3]f32{m.vertices[0], m.vertices[1], m.vertices[2]}
	highest := lowest

	for i := 3; i < len(m.vertices); i += 3 {
		vertex := [3]f32{m.vertices[i], m.vertices[i + 1], m.vertices[i + 2]}
		for coord, j in vertex {
			if coord < lowest[j] {
				lowest[j] = coord
			}
			if coord > highest[j] {
				highest[j] = coord
			}
		}
	}
	center_vec = (lowest + highest) / 2
	return 
}
