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

mat_rotate :: proc(angle: f32, vec: Vec3) -> Mat4 {
	c := math.cos(angle)
	s := math.sin(angle)

	a := normalize(vec)
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
