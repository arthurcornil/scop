package scene

import "core:math/linalg"
import "../vmath"

Object :: struct {
	center: vmath.Vec3,
	angle: f32
}

update :: proc(o: ^Object, dt: f32) {
	o.angle += dt * 0.8
}

get_model_mat :: proc(o: Object) -> vmath.Mat4 {
	return vmath.mat_rotate(o.angle, WORLD_UP) *
		linalg.matrix4_translate(-o.center)
}
