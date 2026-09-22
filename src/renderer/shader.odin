package renderer

import "../errors"
import "core:fmt"

import gl "vendor:OpenGL"

Shader :: struct {
	id: u32,
	u_model, u_view, u_proj: i32
}

// Simpler Odin way with load_shaders_source() helper
//
// load_shader :: proc() -> (s: Shader, err: errors.Error) {
// 	vertex_shader := string(#load("../shaders/vertex.glsl"))
// 	fragment_shader := string(#load("../shaders/fragment.glsl"))
//
// 	ok: bool
// 	s.id, ok = gl.load_shaders_source(vertex_shader, fragment_shader)
// 	if !ok {
// 		return {}, .Compilation_Error
// 	}
//
// 	s.u_model = gl.GetUniformLocation(s.id, "model")
// 	s.u_view = gl.GetUniformLocation(s.id, "view")
// 	s.u_proj = gl.GetUniformLocation(s.id, "projection")
// 	return
// }

//The OpenGL way as requested by the subject
compile_shader :: proc(src: cstring, shader_type: u32) -> (id: u32, err: errors.Error) {
	id = gl.CreateShader(shader_type)
	src := src
	gl.ShaderSource(id, 1, &src, nil)
	gl.CompileShader(id)

	ok: i32
	gl.GetShaderiv(id, gl.COMPILE_STATUS, &ok)
	if ok == 0 {
		log_len: i32
		gl.GetShaderiv(id, gl.INFO_LOG_LENGTH, &log_len)

		log_buf := make([]u8, log_len)
		defer delete(log_buf)

		gl.GetShaderInfoLog(id, log_len, nil, raw_data(log_buf))
		fmt.eprintln(string(log_buf))

		gl.DeleteShader(id)
		return 0, .Compilation_Error
	}
	return
}

create_program :: proc() -> (s: Shader, err: errors.Error) {
	vertex_shader_src := cstring(#load("../shaders/vertex.glsl"))
	fragment_shader_src := cstring(#load("../shaders/fragment.glsl"))

	vertex := compile_shader(vertex_shader_src, gl.VERTEX_SHADER) or_return
	defer gl.DeleteShader(vertex)

	fragment := compile_shader(fragment_shader_src, gl.FRAGMENT_SHADER) or_return
	defer gl.DeleteShader(fragment)

	s.id = gl.CreateProgram()
	gl.AttachShader(s.id, vertex)
	gl.AttachShader(s.id, fragment)
	gl.LinkProgram(s.id)

	ok: i32
	gl.GetProgramiv(s.id, gl.LINK_STATUS, &ok)
	if ok == 0 {
		log_len: i32
		gl.GetProgramiv(s.id, gl.INFO_LOG_LENGTH, &log_len)

		log_buf := make([]u8, log_len)
		defer delete(log_buf)

		gl.GetProgramInfoLog(s.id, log_len, nil, raw_data(log_buf))
		fmt.eprintln(string(log_buf))

		gl.DeleteProgram(s.id)
		return {}, .Compilation_Error
	}

	s.u_model = gl.GetUniformLocation(s.id, "model")
	s.u_view = gl.GetUniformLocation(s.id, "view")
	s.u_proj = gl.GetUniformLocation(s.id, "projection")
	return
}

program_destroy :: proc(s: Shader) {
	gl.DeleteProgram(s.id)
}
