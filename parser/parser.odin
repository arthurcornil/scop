package odin

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

import "../mesh"
import "../errors"

parse_vertex :: proc(line: string) -> (vertex: [3]f32, err: errors.Parsing_Error) {
	tokens := strings.split(line, " ")
	defer delete(tokens)

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

parse_face :: proc(line: string) -> (face: []i32, err: errors.Parsing_Error) {
	tokens := strings.split(line, " ")
	defer delete(tokens)

	if tokens[0] != "f" {
		return []i32{}, .Not_A_Face
	}
	if len(tokens) < 4 {
		return []i32{}, .Wrong_Number_Of_Attributes
	}

	face = make([]i32, len(tokens) - 1)
	for token, i in tokens {
		if i == 0 do continue
		attribute, ok := strconv.parse_i64(token)
		if !ok {
			delete(face)
			return []i32{}, .Wrong_Format
		}
		face[i - 1] = i32(attribute)
	}
	return face, nil
}

parse :: proc(file_name: string, m: ^mesh.Mesh) -> (err: errors.Error) {
	data: []u8
	data, err = os.read_entire_file(file_name, context.allocator)
	if err != nil {
		return err
	}

	content := string(data)
	for line in strings.split_lines_iterator(&content) {
		normalized := strings.trim(line, " ")
		if len(normalized) == 0 || normalized[0] == '#' {
			continue
		}
		switch normalized[0] {
		case 'v':
			//TODO: handle vn, ...
			vertex: [3]f32
			vertex, err = parse_vertex(normalized)
			if err != nil {
				return err
			}
			append(&m.vertices, ..vertex[:])
		case 'f':
			face: []i32
			face, err = parse_face(normalized)
			if err != nil {
				return err
			}
			append(&m.faces, ..face)
			delete(face)
		}
	}
	return nil
}
