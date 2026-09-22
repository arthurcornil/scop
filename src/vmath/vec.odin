package vmath

import "core:math"

Vec3 :: [3]f32

get_len :: proc(vec: Vec3) -> f32 {
	return math.sqrt(
		vec[0] * vec[0] +
		vec[1] * vec[1] +
		vec[2] * vec[2]
	)
}

normalize :: proc(vec: Vec3) -> Vec3 {
	len := get_len(vec)
	if len == 0 do return Vec3{}

	vec := vec
	vec[0] /= len
	vec[1] /= len
	vec[2] /= len
	return vec
}
