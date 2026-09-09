package main

import gl "vendor:OpenGL"

Shader_Program :: u32

get_shader_program :: proc() -> (sp: Shader_Program, err: Error) {
	vertex_shader := string(#load("shaders/vertex.glsl"))
	fragment_shader := string(#load("shaders/fragment.glsl"))

	ok: bool
	sp, ok = gl.load_shaders_source(vertex_shader, fragment_shader)
	if !ok {
		return 0, .Compilation_Error
	}
	return
}
