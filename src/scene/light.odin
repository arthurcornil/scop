package scene

import "../vmath"

Light_Source :: struct {
	world_pos: vmath.Vec3,
	view_pos: vmath.Vec4
}

@private
v3_to_v4 :: proc(v: vmath.Vec3) -> vmath.Vec4 {
	return {v.x, v.y, v.z, 1}
}

get_light_view :: proc(c: Camera, lw: vmath.Vec3) -> [4]f32 { return get_view_mat(c) * v3_to_v4(lw) }

update_light :: proc(l: ^Light_Source, c: Camera) {
	l.view_pos = get_light_view(c, l.world_pos)
}


make_light :: proc(radius: f32) -> (light: Light_Source) {
	light.world_pos = {radius * 1.8, radius * 2.5, radius * 2}
	return
}
