package main

import "core:fmt"

import "./parser"
import "./renderer"
import "./mesh"
import "./errors"
import "./platform"
import "./scene"
import "./vmath"

Environment :: struct {
	model: scene.Object,
	camera: scene.Camera,
	light: scene.Light_Source,
	gpu_data: renderer.Data
	// gpu_mesh: renderer.GPU_Mesh,
	// shader: renderer.Shader
}

init_env :: proc(path: string) -> (env: Environment, err: errors.Error) {
	m := mesh.Mesh{}
	if err = parser.parse(path, &m); err != nil {
		return {}, err
	}

	center := mesh.center(m)
	radius := mesh.radius(center, m)
	env.model = scene.Object{center = center, is_rotating = true}

	env.camera = scene.make_cam(radius)
	env.light = scene.make_light(radius)

	if env.gpu_data, err = renderer.init_data(&m); err != nil {
		return {}, err
	}
	mesh.destroy(&m)
	return
}

handle_inputs :: proc(win: platform.Window, env: ^Environment) {
	switch {
	case platform.key_pressed(.Escape):
		platform.close(win)
	case platform.key_pressed(.Enter):
		env.model.is_rotating = !env.model.is_rotating
	}
	if delta, ok := platform.mouse_drag_delta().?; ok {
		scene.orbit(&env.camera, ([2]f32)(delta))
	}
}

run :: proc(path: string) -> (err: errors.Error) {
	win := platform.init_window() or_return
	defer platform.destroy(win)

	env := init_env(path) or_return
	defer renderer.destroy(&env.gpu_data)

	last := platform.time()

	for !platform.should_close(win) {
		platform.poll_events(win)
		handle_inputs(win, &env)

		now := platform.time()
		scene.update(&env.model, f32(now - last))
		scene.update(&env.light, env.camera)
		last = now

		renderer.begin_frame()
		obj_trans_pipeline := renderer.Trans_Pipeline{
			scene.get_model_mat(env.model),
			scene.get_view_mat(env.camera),
			scene.get_proj_mat(env.camera, platform.aspect(win)),
		}
		light_trans_pipeline := renderer.Trans_Pipeline{
			scene.get_model_mat(env.light),
			scene.get_view_mat(env.camera),
			scene.get_proj_mat(env.camera, platform.aspect(win))
		}
		renderer.draw_scene(
			env.gpu_data,
			obj_trans_pipeline,
			light_trans_pipeline,
			env.light.view_pos
		)
		platform.swap_buffers(win)
	}
	return nil
}
