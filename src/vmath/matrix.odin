package vmath

import "core:math"

Mat4 :: matrix[4, 4]f32

to_radians :: proc (angle: f32) -> f32 {
	return angle * (math.PI / 180)
}

mat_rotate_x :: proc(angle: f32) -> Mat4 {
	return Mat4{
		1, 0, 0, 0,
		0, math.cos(angle), -math.sin(angle), 0,
		0, math.sin(angle), math.cos(angle), 0,
		0, 0, 0, 1
	}
}

mat_rotate_y :: proc(angle: f32) -> Mat4 {
	return Mat4{
		math.cos(angle), 0, math.sin(angle), 0,
		0, 1, 0, 0,
		-math.sin(angle), 0, math.cos(angle), 0,
		0, 0, 0, 1
	}
}

mat_rotate_z :: proc(angle: f32) -> Mat4 {
	return Mat4{
		math.cos(angle), -math.sin(angle), 0, 0,
		math.sin(angle), math.cos(angle), 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	}
}

mat_rotate :: proc(angle: f32, vec: Vec3) -> (Mat4) {
	c := math.cos(angle)
	s := math.sin(angle)

	a := vec_normalize(vec)
	t := a * (1-c)

	rot: Mat4

	rot[0][0] = c + t[0]*a[0]
	rot[0][1] = 0 + t[0]*a[1] + s*a[2]
	rot[0][2] = 0 + t[0]*a[2] - s*a[1]
	rot[0][3] = 0

	rot[1][0] = 0 + t[1]*a[0] - s*a[2]
	rot[1][1] = c + t[1]*a[1]
	rot[1][2] = 0 + t[1]*a[2] + s*a[0]
	rot[1][3] = 0

	rot[2][0] = 0 + t[2]*a[0] + s*a[1]
	rot[2][1] = 0 + t[2]*a[1] - s*a[0]
	rot[2][2] = c + t[2]*a[2]
	rot[2][3] = 0
	rot[3][3] = 1

	return rot
}

mat_translate :: proc(vec: Vec3) -> Mat4 {
	return {
		1, 0, 0, vec.x,
		0, 1, 0, vec.y,
		0, 0, 1, vec.z,
		0, 0, 0, 1
	}
}

mat_look_at :: proc(eye, target, worldUp: Vec3) -> Mat4 {
	forward := vec_normalize(target - eye)
	right := vec_normalize(vec_cross(forward, worldUp))
	up := vec_cross(right, forward)

	return {
		right[0], right[1], right[2], -vec_dot(right, eye),
		up[0], up[1], up[2], -vec_dot(up, eye),
		-forward[0], -forward[1], -forward[2], vec_dot(forward, eye),
		0, 0, 0, 1
	}
}

mat_perspective :: proc(fovy, aspect, near, far: f32, flip_z_axis := true) -> (m: Mat4) {
	tan_half_fovy := math.tan(0.5 * fovy)

	m[0, 0] = 1 / (aspect * tan_half_fovy)
	m[1, 1] = 1 / (tan_half_fovy)
	m[2, 2] = (far + near) / (far - near)
	m[3, 2] = 1
	m[2, 3] = -2 * far * near / (far - near)

	if flip_z_axis {
		m[2] = -m[2]
	}

	return
}
