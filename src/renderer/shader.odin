package renderer

import "../errors"

import gl "vendor:OpenGL"

Shader :: struct {
	id: u32,
	u_model, u_view, u_proj: i32
}

//TODO: load & compile without odin helpers
load_shader :: proc() -> (s: Shader, err: errors.Error) {
	vertex_shader := string(#load("../shaders/vertex.glsl"))
	fragment_shader := string(#load("../shaders/fragment.glsl"))

	ok: bool
	s.id, ok = gl.load_shaders_source(vertex_shader, fragment_shader)
	if !ok {
		return {}, .Compilation_Error
	}

	s.u_model = gl.GetUniformLocation(s.id, "model")
	s.u_view = gl.GetUniformLocation(s.id, "view")
	s.u_proj = gl.GetUniformLocation(s.id, "projection")
	return
}

//TODO: destroy shaders
