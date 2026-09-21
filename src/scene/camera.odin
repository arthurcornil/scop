package scene

import "core:math/linalg"

Vec3 :: [3]f32
Mat4 :: matrix[4, 4]f32
WORLD_UP :: Vec3{0.0, 1.0, 0.0}

Camera :: struct {
	pos, target, up : Vec3,
	fov, near, far: f32
}

make_cam :: proc(pos, target: Vec3) -> Camera {
	return Camera{
		pos    = pos,
		target = target,
		up     = WORLD_UP,
		fov    = linalg.to_radians(f32(45)),
		near   = 0.1,
		far    = 100,
	}
}

get_view_mat :: proc(c: Camera) -> Mat4 {
	return linalg.matrix4_look_at(c.pos, c.target, c.up)
}

get_proj_mat :: proc(c: Camera, aspect: f32) -> Mat4 {
	return linalg.matrix4_perspective(
		c.fov,
		aspect,
		c.near,
		c.far
	)
}
