package parser

import "core:strings"
import "core:strconv"

import "../mesh"
import "../errors"

Face_Corner :: struct {
	pos_id: int,
	normal_id: int,
	uv_id: int
}

@private
parse_textcoord :: proc(tokens: []string) -> (textcoord: [2]f32, err: errors.Parsing_Error) {
	if len(tokens) < 3 || len(tokens) > 4 {
		return {}, .Wrong_Number_Of_Attributes
	}
	for i in 1..=2 {
		attribute, ok := strconv.parse_f32(tokens[i])
		if !ok {
			return {}, .Wrong_Format
		}
		textcoord[i - 1] = attribute
	}
	return
}

@private
resolve_id :: proc(id, list_len: int) -> (resolved: int, err: errors.Parsing_Error) {
	resolved = id
	switch {
	case id == 0:
		return {}, .Zero_Face_Index
	case id > list_len || id < -list_len:
		return {}, .Out_Of_Bounds
	case id < 0:
		resolved = list_len + id + 1
	}
	return resolved - 1, nil
}

@private
face_corner_to_vertex :: proc(c: Face_Corner, m: mesh.Mesh) -> (v: mesh.Vertex) {
	v.pos = m.raw_vertices[c.pos_id]
	if c.normal_id >= 0 {
		v.normal = m.normals[c.normal_id]
	}
	if c.uv_id >= 0 {
		v.textcoords = m.textcoords[c.uv_id]
	}
	return
}

@private
parse_corner :: proc(value: string, m: mesh.Mesh) -> (vd: Face_Corner, err: errors.Parsing_Error) {
	it := value
	i := 0
	vd = {
		pos_id = -1,
		uv_id = -1,
		normal_id = -1
	}
	for token in strings.split_iterator(&it, "/") {	
		if len(token) == 0 {
			i += 1
			continue
		}
		idx, ok := strconv.parse_int(token)
		if !ok {
			return {}, .Wrong_Format
		}

		// f [v id]/[vt id]/[vn id]
		//     0       1       2
		switch i {
		case 0:
			vd.pos_id = resolve_id(idx, len(m.raw_vertices)) or_return
		case 1:
			vd.uv_id = resolve_id(idx, len(m.textcoords)) or_return
		case 2:
			vd.normal_id = resolve_id(idx, len(m.normals)) or_return
		}
		i += 1
	}
	if i > 3 {
		return {}, .Wrong_Number_Of_Attributes
	}
	return
}

@private
parse_corners :: proc(tokens: []string, m: mesh.Mesh) -> (corners: []Face_Corner, err: errors.Parsing_Error) {
	if tokens[0] != "f" {
		return {}, .Wrong_Tag
	}
	if len(tokens) < 4 {
		return {}, .Wrong_Number_Of_Attributes
	}

	corners = make([]Face_Corner, len(tokens) - 1)
	for token, i in tokens {
		if i == 0 do continue
		corner := parse_corner(token, m) or_return
		corners[i - 1] = corner
	}
	return
}

@private
create_vertices :: proc(corners: []Face_Corner, m: ^mesh.Mesh, unique_corners: ^map[Face_Corner]u32) ->
	(indices: []u32, err: errors.Parsing_Error) {
	indices = make([]u32, len(corners))
	for corner, i in corners {
		index: u32
		found: bool
		if index, found = unique_corners[corner]; !found {
			append(&m.vertices, face_corner_to_vertex(corner, m^))
			index = u32(len(m.vertices) - 1)
			unique_corners[corner] = index
		}
		indices[i] = u32(index)
	}
	return
}
