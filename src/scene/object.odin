package scene

import "core:math/linalg"

Object :: struct {
	center: Vec3,
	angle: f32
}

update :: proc(o: ^Object, dt: f32) {
	o.angle += dt * 0.8
}

get_model_mat :: proc(o: Object) -> Mat4 {
	return linalg.matrix4_rotate(o.angle, WORLD_UP) *
		linalg.matrix4_translate(-o.center)
}
