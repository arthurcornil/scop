package parser

import "core:os"
import "core:strings"
import "core:strconv"

import "../mesh"
import "../errors"
import "../vmath"

@private
parse_float_attr :: proc(tokens: []string) -> (values: [3]f32, err: errors.Parsing_Error) {
	if len(tokens) != 4 {
		return {}, .Wrong_Number_Of_Attributes
	}
	for token, i in tokens {
		if i == 0 do continue
		attribute, ok := strconv.parse_f32(token)
		if !ok {
			return {}, .Wrong_Format
		}
		values[i - 1] = attribute
	}
	return values, nil
}

workout_normals :: proc(m: ^mesh.Mesh, vertex_pos_ids: [dynamic]int) {
	normals := make([][3]f32, len(m.raw_vertices))
	defer delete(normals)
	for i := 0; i < len(m.indices); i += 3 {
		i0, i1, i2 := m.indices[i], m.indices[i + 1], m.indices[i + 2]
		a, b, c := m.vertices[i0].pos, m.vertices[i1].pos, m.vertices[i2].pos
		normal := vmath.vec_normalize(vmath.vec_cross(b - a, c - a))
		normals[vertex_pos_ids[i0]] += normal
		normals[vertex_pos_ids[i1]] += normal
		normals[vertex_pos_ids[i2]] += normal
	}
	for &v, i in m.vertices {
		if v.normal == {0.0, 0.0, 0.0} {
			v.normal = normals[vertex_pos_ids[i]]
		}
	}
}

parse :: proc(file_name: string, m: ^mesh.Mesh) -> (err: errors.Error) {
	data: []u8
	data, err = os.read_entire_file(file_name, context.allocator)
	defer delete(data)
	if err != nil {
		return err
	}

	unique_corners: map[Face_Corner]u32
	defer delete(unique_corners)
	vertex_pos_ids: [dynamic]int
	defer delete(vertex_pos_ids)
	content := string(data)
	for line in strings.split_lines_iterator(&content) {
		//Might wanna switch to strings field_iterator() instead fields()
		tokens := strings.fields(line)
		defer delete(tokens)
		if len(tokens) == 0 {
			continue
		}
		switch tokens[0] {
		case "#":
			continue
		case "v":
			vertex := parse_float_attr(tokens) or_return
			append(&m.raw_vertices, vertex)
		case "vn":
			normal := parse_float_attr(tokens) or_return
			append(&m.normals, normal)
		case "vt":
			textcoord := parse_textcoord(tokens) or_return
			append(&m.textcoords, textcoord)
		case "f":
			corners := parse_corners(tokens, m^) or_return
			indices := create_vertices(corners, m, &unique_corners, &vertex_pos_ids)
			delete(corners)
			for i in 1..<len(indices) - 1 {
				append(&m.indices, indices[0], indices[i], indices[i + 1])
			}
			delete(indices)
		}
	}
	workout_normals(m, vertex_pos_ids)
	return nil
}
