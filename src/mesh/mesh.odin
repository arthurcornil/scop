package mesh

import "../vmath"

Vertex :: struct {
	pos: [3]f32,
	normal: [3]f32,
	textcoords: [2]f32
}

Mesh :: struct {
	raw_vertices: [dynamic][3]f32,
	indices: [dynamic]u32,
	normals: [dynamic][3]f32,
	textcoords: [dynamic][2]f32,
	vertices: [dynamic]Vertex
}

destroy :: proc(m: ^Mesh) {
	delete(m.raw_vertices)
	delete(m.vertices)
	delete(m.indices)
	delete(m.normals)
	delete(m.textcoords)
	m^ = {}
}

center :: proc(m: Mesh) -> (center_vec: [3]f32) {
	lowest := m.raw_vertices[0]
	highest := lowest

	for vertex in m.raw_vertices {
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

radius :: proc(center: vmath.Vec3, m: Mesh) -> (radius: f32) {
	for v in m.raw_vertices {
		radius = max(radius, vmath.vec_len(v - center))
	}
	return
}
