package renderer

import gl "vendor:OpenGL"

import "../mesh"
import "../errors"
import "../vmath"

BACKGROUND_COLOR :: [4]f32{0.1, 0.1, 0.1, 1.0}
VERTEX_SRC :: #load("../shaders/vertex.glsl", cstring)
LIT_FRAGMENT_SRC :: #load("../shaders/lit_fragment.glsl", cstring)
DEFAULT_FRAGMENT_SRC :: #load("../shaders/default_fragment.glsl", cstring)
DEFAULT_TEXTURE_PATH :: "./resources/nggyu.bmp"
TEXTURE_FADE_DURATION :: 1.0

Trans_Pipeline :: struct {
	model: vmath.Mat4,
	view: vmath.Mat4,
	projection: vmath.Mat4,
}

Data :: struct {
	lit_shader: Shader,
	default_shader: Shader,
	obj_mesh: GPU_Mesh,
	light_marker_mesh: GPU_Mesh,
	texture: u32,
	texture_opacity: f32
}

init_data :: proc(m: ^mesh.Mesh) -> (data: Data, err: errors.Error) {
	data.obj_mesh = upload(m.vertices[:], m.indices[:])
	if data.lit_shader, err = create_program(VERTEX_SRC, LIT_FRAGMENT_SRC); err != nil {
		return {}, err
	}
	data.light_marker_mesh = upload(LIGHT_MARKER_VERTICES[:], LIGHT_MARKER_INDICES[:])
	if data.default_shader, err = create_program(VERTEX_SRC, DEFAULT_FRAGMENT_SRC); err != nil {
		return {}, err
	}
	data.texture = load_texture(DEFAULT_TEXTURE_PATH) or_return
	return
}

update_texture_opacity :: proc(d: ^Data, visible: bool, delta: f32) {
	target: f32 = 1.0 if visible else 0.0
	step := delta / TEXTURE_FADE_DURATION
	if d.texture_opacity < target {
		d.texture_opacity = min(d.texture_opacity + step, target)
	} else {
		d.texture_opacity = max(d.texture_opacity - step, target)
	}
}

destroy :: proc(d: ^Data) {
	gpu_mesh_destroy(&d.obj_mesh)
	gpu_mesh_destroy(&d.light_marker_mesh)
	program_destroy(d.lit_shader)
	program_destroy(d.default_shader)
}

@private
get_color_attr :: proc(color: [4]f32) -> (r: f32, g: f32, b: f32, alpha: f32) {
	r = color[0]
	g = color[1]
	b = color[2]
	alpha = color[3]
	return
}

begin_frame :: proc() {
	gl.ClearColor(get_color_attr(BACKGROUND_COLOR))
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

draw_scene :: proc(d: Data, obj_trans: Trans_Pipeline, light_trans: Trans_Pipeline, light_pos: [4]f32) {
	model, view, proj := obj_trans.model, obj_trans.view, obj_trans.projection
	light_pos := light_pos

	gl.UseProgram(d.lit_shader.id)

	gl.UniformMatrix4fv(d.lit_shader.u_model, 1, gl.FALSE, &model[0][0])
	gl.UniformMatrix4fv(d.lit_shader.u_view, 1, gl.FALSE, &view[0][0])
	gl.UniformMatrix4fv(d.lit_shader.u_proj, 1, gl.FALSE, &proj[0][0])
	gl.Uniform4fv(d.lit_shader.u_light_pos, 1, &light_pos[0])
	gl.Uniform1f(d.lit_shader.u_mix, d.texture_opacity)

	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	gl.BindVertexArray(d.obj_mesh.vao)
	defer gl.BindVertexArray(0)
	gl.DrawElements(gl.TRIANGLES, d.obj_mesh.count_indices, gl.UNSIGNED_INT, nil)

	model, view, proj = light_trans.model, light_trans.view, light_trans.projection
	gl.UseProgram(d.default_shader.id)

	gl.UniformMatrix4fv(d.default_shader.u_model, 1, gl.FALSE, &model[0][0])
	gl.UniformMatrix4fv(d.default_shader.u_view, 1, gl.FALSE, &view[0][0])
	gl.UniformMatrix4fv(d.default_shader.u_proj, 1, gl.FALSE, &proj[0][0])

	gl.BindTexture(gl.TEXTURE_2D, d.texture)
	gl.BindVertexArray(d.light_marker_mesh.vao)
	gl.DrawElements(gl.TRIANGLES, d.light_marker_mesh.count_indices, gl.UNSIGNED_INT, nil)
}
