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
		fmt.println(tokens)
		return [3]f32{}, .Wrong_Number_Of_Attributes
	}
	for token, i in tokens {
		if i == 0 do continue
		if i > 4 {
			return [3]f32{}, .Vertex_Format
		}
		attribute, ok := strconv.parse_f32(token)
		if !ok {
			return [3]f32{}, .Vertex_Format
		}
		vertex[i - 1] = attribute
	}
	return vertex, nil
}

parse :: proc(file_name: string, m: ^mesh.Mesh) -> errors.Error {
	data, err := os.read_entire_file(file_name, context.allocator)
	if err != nil {
		return err
	}
	content := string(data)
	for line in strings.split_lines_iterator(&content) {
		normalized := strings.trim(line, " ")
		if len(normalized) == 0 || normalized[0] == '#' {
			continue
		}
		vertex, err := parse_vertex(normalized)
		if err == .Not_A_Vertex {
			continue
		} else if err != nil {
			delete(m.vertices)
			return err
		}
		append(&m.vertices, ..vertex[:])
	}
	return nil
}
