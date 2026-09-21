package scene

import "core:math/linalg"
import "../vmath"

WORLD_UP :: vmath.Vec3{0.0, 1.0, 0.0}

Camera :: struct {
	pos, target, up : vmath.Vec3,
	fov, near, far: f32
}

make_cam :: proc(pos, target: vmath.Vec3) -> Camera {
	return Camera{
		pos    = pos,
		target = target,
		up     = WORLD_UP,
		fov    = vmath.to_radians(f32(45)),
		near   = 0.1,
		far    = 100,
	}
}

get_view_mat :: proc(c: Camera) -> vmath.Mat4 {
	return linalg.matrix4_look_at(c.pos, c.target, c.up)
}

get_proj_mat :: proc(c: Camera, aspect: f32) -> vmath.Mat4 {
	return linalg.matrix4_perspective(
		c.fov,
		aspect,
		c.near,
		c.far
	)
}
