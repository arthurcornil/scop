package parser

import "core:os"
import "core:strings"
import "core:strconv"

import "../mesh"
import "../errors"

parse_vertex :: proc(tokens: []string) -> (vertex: [3]f32, err: errors.Parsing_Error) {
	if tokens[0] != "v" {
		return [3]f32{}, .Not_A_Vertex
	}
	if len(tokens) != 4 {
		return [3]f32{}, .Wrong_Number_Of_Attributes
	}
	for token, i in tokens {
		if i == 0 do continue
		attribute, ok := strconv.parse_f32(token)
		if !ok {
			return [3]f32{}, .Wrong_Format
		}
		vertex[i - 1] = attribute
	}
	return vertex, nil
}

parse_face :: proc(tokens: []string, m: mesh.Mesh) -> (face: []u32, err: errors.Parsing_Error) {
	if tokens[0] != "f" {
		return []u32{}, .Not_A_Face
	}
	if len(tokens) < 4 {
		return []u32{}, .Wrong_Number_Of_Attributes
	}

	face = make([]u32, len(tokens) - 1)
	for token, i in tokens {
		if i == 0 do continue
		attribute, ok := strconv.parse_int(token)
		if !ok {
			delete(face)
			return []u32{}, .Wrong_Format
		}
		vertex_count := len(m.vertices) / 3
		switch {
		case attribute == 0:
			return []u32{}, .Zero_Face_Index
		case attribute > vertex_count || attribute < -vertex_count:
			return []u32{}, .Out_Of_Bounds
		case attribute < 0:
			attribute = vertex_count + attribute + 1
		}
		face[i - 1] = u32(attribute - 1)
	}
	return face, nil
}

parse :: proc(file_name: string, m: ^mesh.Mesh) -> (err: errors.Error) {
	data: []u8
	data, err = os.read_entire_file(file_name, context.allocator)
	defer delete(data)
	if err != nil {
		return err
	}

	content := string(data)
	for line in strings.split_lines_iterator(&content) {
		tokens := strings.fields(line)
		defer delete(tokens)
		if len(tokens) == 0 {
			continue
		}
		switch tokens[0] {
		case "#":
			continue
		//TODO: handle vn, ...
		case "v":
			vertex := parse_vertex(tokens) or_return
			append(&m.vertices, ..vertex[:])
		case "f":
			face := parse_face(tokens, m^) or_return
			for i in 1..<len(face) - 1 {
				append(&m.indices, face[0], face[i], face[i + 1])
			}
			delete(face)
		}
	}
	return nil
}
