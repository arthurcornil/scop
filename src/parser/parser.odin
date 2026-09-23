package parser

import "core:os"
import "core:strings"
import "core:strconv"

import "../mesh"
import "../errors"

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

parse :: proc(file_name: string, m: ^mesh.Mesh) -> (err: errors.Error) {
	data: []u8
	data, err = os.read_entire_file(file_name, context.allocator)
	defer delete(data)
	if err != nil {
		return err
	}

	unique_corners: map[Face_Corner]u32
	defer delete(unique_corners)
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
			indices := create_vertices(corners, m, &unique_corners) or_return
			delete(corners)
			for i in 1..<len(indices) - 1 {
				append(&m.indices, indices[0], indices[i], indices[i + 1])
			}
			delete(indices)
		}
	}
	return nil
}
