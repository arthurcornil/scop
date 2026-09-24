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
	gpu_mesh: renderer.GPU_Mesh,
	shader: renderer.Shader
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

	env.gpu_mesh = renderer.upload(&m)
	mesh.destroy(&m)

	if env.shader, err = renderer.create_program(); err != nil {
		return {}, err
	}
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
	defer renderer.destroy(&env.gpu_mesh)
	defer renderer.destroy(env.shader)

	last := platform.time()

	for !platform.should_close(win) {
		platform.poll_events(win)
		handle_inputs(win, &env)

		now := platform.time()
		scene.update(&env.model, f32(now - last))
		scene.update(&env.light, env.camera)
		last = now

		renderer.begin_frame()
		renderer.draw_mesh(
			env.shader,
			env.gpu_mesh,
			scene.get_model_mat(env.model),
			scene.get_view_mat(env.camera),
			scene.get_proj_mat(env.camera, platform.aspect(win)),
			env.light.view_pos
		)
		platform.swap_buffers(win)
	}
	return nil
}
