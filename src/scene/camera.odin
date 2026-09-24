package scene

import "core:math"
import "../vmath"

WORLD_UP :: vmath.Vec3{0.0, 1.0, 0.0}

Camera :: struct {
	pos, target, up : vmath.Vec3,
	fov, near, far: f32
}

make_cam :: proc(radius: f32) -> Camera {
	fov := vmath.to_radians(f32(45))
	dist := radius / math.sin(fov / 2) * 1.15
	pos: vmath.Vec3 = {0, 0, dist}
	return Camera{
		pos    = pos,
		target = {0, 0, 0},
		up     = WORLD_UP,
		fov    = fov,
		near   = max(dist - radius * 1.5, radius * 0.01),
		far    = dist + radius * 1.5,
	}
}

orbit :: proc(c: ^Camera, delta: [2]f32) {
      offset := c.pos - c.target
      radius := vmath.vec_len(offset)

      yaw := math.atan2(offset.x, offset.z) - delta[0] * 0.01
      pitch := math.asin(offset.y / radius) + delta[1] * 0.01
      pitch = clamp(pitch, -math.PI/2 + 0.01, math.PI/2 - 0.01)

      c.pos = c.target + vmath.Vec3{
              radius * math.cos(pitch) * math.sin(yaw),
              radius * math.sin(pitch),
              radius * math.cos(pitch) * math.cos(yaw),
      }
}

get_view_mat :: proc(c: Camera) -> vmath.Mat4 {
	return vmath.mat_look_at(c.pos, c.target, c.up)
}

get_proj_mat :: proc(c: Camera, aspect: f32) -> vmath.Mat4 {
	return vmath.mat_perspective(
		c.fov,
		aspect,
		c.near,
		c.far
	)
}
