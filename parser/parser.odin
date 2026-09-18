package odin

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

import "../obj"

Error :: union #shared_nil {
	os.Error,
	Parsing_Error
}

Parsing_Error :: enum {
	None = 0,
	Not_A_Vertex,
	Vertex_Format,
	Wrong_Number_Of_Attributes
}

parse_vertex :: proc(line: string) -> (vertex: [3]f32, err: Parsing_Error) {
	tokens := strings.split(line, " ")
	defer delete(tokens)

	if tokens[0] != "v" {
		return [3]f32{}, Parsing_Error.Not_A_Vertex
	}
	if len(tokens) != 4 {
		fmt.println(tokens)
		return [3]f32{}, Parsing_Error.Wrong_Number_Of_Attributes
	}
	for token, i in tokens {
		if i == 0 do continue
		if i > 4 {
			return [3]f32{}, Parsing_Error.Vertex_Format
		}
		attribute, ok := strconv.parse_f32(token)
		if !ok {
			return [3]f32{}, Parsing_Error.Vertex_Format
		}
		vertex[i - 1] = attribute
	}
	return vertex, nil
}

parse :: proc(file_name: string, obj: ^obj.Obj) -> Error {
	data, err := os.read_entire_file(file_name, context.allocator)
	if err != nil {
		return err
	}
	content := string(data)
	for line in strings.split_lines_iterator(&content) {
		normalized := strings.trim(line, " ")
		if normalized[0] == '#' {
			continue 
		}
		vertex, err := parse_vertex(line)
		if err == Parsing_Error.Not_A_Vertex {
			continue 
		} else if err != nil {
			return err
		}
		append(&obj.vertices, ..vertex[:])
	}
	return nil
}
