package scene

import "../vmath"

ROTATION_SPEED :: 1.5

Object :: struct {
	center: vmath.Vec3,
	position: vmath.Vec3,
	yaw: f32,
	pitch: f32,
	roll: f32,
	rotation: vmath.Mat4,
	is_rotating: bool
}

rotate_obj :: proc(o: ^Object, axis: int, delta: f32) {
	switch axis {
	case 0:
		o.rotation *= vmath.mat_rotate_x(delta * ROTATION_SPEED)
	case 1:
		o.rotation *= vmath.mat_rotate_y(delta * ROTATION_SPEED)
	case 2:
		o.rotation *= vmath.mat_rotate_z(delta * ROTATION_SPEED)
	}
}

update_obj :: proc(o: ^Object, dt: f32) {
	if (!o.is_rotating) do return 
	o.rotation *= vmath.mat_rotate_y(dt * 0.8)
}

get_model_mat_obj :: proc(o: Object) -> vmath.Mat4 {
	return (
		vmath.mat_translate(o.position) *
		o.rotation *
		vmath.mat_translate(-o.center)
	)
}
