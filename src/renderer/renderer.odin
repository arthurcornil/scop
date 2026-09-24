package renderer

import gl "vendor:OpenGL"

BACKGROUND_COLOR :: [4]f32{0.1, 0.1, 0.1, 1.0}

destroy :: proc{gpu_mesh_destroy, program_destroy}

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

draw_mesh :: proc(s: Shader, g: GPU_Mesh, model, view, proj: matrix[4, 4]f32, light_pos: [4]f32) {
	model, view, proj, light_pos := model, view, proj, light_pos

	gl.UseProgram(s.id)

	gl.UniformMatrix4fv(s.u_model, 1, gl.FALSE, &model[0][0])
	gl.UniformMatrix4fv(s.u_view, 1, gl.FALSE, &view[0][0])
	gl.UniformMatrix4fv(s.u_proj, 1, gl.FALSE, &proj[0][0])
	gl.Uniform4fv(s.u_light_pos, 1, &light_pos[0])

	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	gl.Enable(gl.CULL_FACE);  
	gl.BindVertexArray(g.vao)
	defer gl.BindVertexArray(0)
	gl.DrawElements(gl.TRIANGLES, g.count_indices, gl.UNSIGNED_INT, nil)
}
