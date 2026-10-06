package main

import "core:fmt"

import "./parser"
import "./renderer"
import "./mesh"
import "./errors"
import "./platform"
import "./scene"
import "./vmath"

AXIS_KEYS := [3]platform.Key{.X, .Y, .Z}
TRANSLATION_SPEED :: 1.0

Environment :: struct {
	model: scene.Object,
	camera: scene.Camera,
	light: scene.Light_Source,
	gpu_data: renderer.Data,
	apply_texture: bool
}

init_env :: proc(path: string) -> (env: Environment, err: errors.Error) {
	m := mesh.Mesh{}
	defer mesh.destroy(&m)
	if err = parser.parse(path, &m); err != nil {
		return {}, err
	}

	center := mesh.center(m)
	radius := mesh.radius(center, m)
	env.model = scene.Object{center = center, is_rotating = false, rotation = 1}

	env.camera = scene.make_cam(radius)
	env.light = scene.make_light(radius)

	if env.gpu_data, err = renderer.init_data(&m); err != nil {
		return {}, err
	}
	return
}

handle_inputs :: proc(win: platform.Window, env: ^Environment, dt: f32) {
	for key, axis in AXIS_KEYS {
		if !platform.key_down(key) do continue
		dir: f32 = platform.shift_down() ? -1 : 1
		if platform.alt_down() {
			scene.rotate_obj(&env.model, axis, dir * dt)
		} else {
			env.model.position[axis] += dir * env.camera.radius * TRANSLATION_SPEED * dt
		}
	}
	switch {
	case platform.key_pressed(.Escape):
		platform.close(win)
	case platform.key_pressed(.Enter):
		env.model.is_rotating = !env.model.is_rotating
	case platform.key_pressed(.T):
		env.apply_texture = !env.apply_texture
	}
	if delta, ok := platform.mouse_drag_delta().?; ok {
		scene.orbit(&env.camera, ([2]f32)(delta))
	}
	if scroll_delta := platform.scroll_delta(); scroll_delta != 0 {
		scene.zoom(&env.camera, f32(scroll_delta))
	}
}

run :: proc(path: string) -> (err: errors.Error) {
	win := platform.init_window() or_return
	defer platform.destroy(win)

	env := init_env(path) or_return
	defer renderer.destroy(&env.gpu_data)

	last := platform.time()
	for !platform.should_close(win) {
		now := platform.time()
		dt := min(f32(now - last), 0.1)
		last = now

		platform.poll_events(win)
		handle_inputs(win, &env, dt)

		scene.update(&env.model, dt)
		scene.update(&env.light, env.camera)
		renderer.update_texture_opacity(&env.gpu_data, env.apply_texture, dt)

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
