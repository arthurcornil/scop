package scene

import "../vmath"

Object :: struct {
	center: vmath.Vec3,
	angle: f32,
	is_rotating: bool
}

update :: proc(o: ^Object, dt: f32) {
	if (!o.is_rotating) do return 
	o.angle += dt * 0.8
}

get_model_mat :: proc(o: Object) -> vmath.Mat4 {
	return vmath.mat_rotate_y(o.angle) * vmath.mat_translate(-o.center)
}
