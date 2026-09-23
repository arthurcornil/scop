package main

import gl "vendor:OpenGL"

import "./parser"
import "./renderer"
import "./mesh"
import "./errors"
import "./platform"
import "./scene"


run :: proc(path: string) -> (err: errors.Error) {
	win := platform.init_window() or_return
	defer platform.destroy(win)

	m := mesh.Mesh{}
	defer mesh.destroy(&m)
	parser.parse(path, &m) or_return
	obj := scene.Object{center = mesh.center(m)}

	gpu_data := renderer.upload(&m)
	defer renderer.destroy(&gpu_data)
	mesh.destroy(&m)

	shader := renderer.create_program() or_return
	defer renderer.destroy(shader)

	cam := scene.make_cam({0, 0, 10}, {0, 0, 0})
	last := platform.time()

	for !platform.should_close(win) {
		platform.process_input(win)

		now := platform.time()
		scene.update(&obj, f32(now - last))
		last = now

		renderer.begin_frame()
		renderer.draw_mesh(
			shader,
			gpu_data,
			scene.get_model_mat(obj),
			scene.get_view_mat(cam),
			scene.get_proj_mat(cam, platform.aspect(win))
		)
		platform.swap_buffers(win)
	}
	return nil
}
