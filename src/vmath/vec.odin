package vmath

import "core:math"

Vec3 :: [3]f32

vec_len :: proc(vec: Vec3) -> f32 {
	return math.sqrt(
		vec[0] * vec[0] +
		vec[1] * vec[1] +
		vec[2] * vec[2]
	)
}

vec_normalize :: proc(vec: Vec3) -> Vec3 {
	return vec / vec_len(vec)
}

vec_cross :: proc(a, b: Vec3) -> Vec3 {
	return {
		a[1] * b[2] - a[2] * b[1],
		a[2] * b[0] - a[0] * b[2],
		a[0] * b[1] - a[1] * b[0]
	}
}

vec_dot :: proc(a, b: Vec3) -> f32 {
	return (
		a[0] * b[0] +
		a[1] * b[1] +
		a[2] * b[2]
	)
}
