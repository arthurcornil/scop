package renderer

import "../mesh"

@(rodata)
LIGHT_MARKER_VERTICES := [6]mesh.Vertex{
	{pos = { 1,  0,  0}}, // 0: +X
	{pos = {-1,  0,  0}}, // 1: -X
	{pos = { 0,  1,  0}}, // 2: +Y
	{pos = { 0, -1,  0}}, // 3: -Y
	{pos = { 0,  0,  1}}, // 4: +Z
	{pos = { 0,  0, -1}}, // 5: -Z
}

@(rodata)
LIGHT_MARKER_INDICES := [24]u32{
	0, 2, 4, // +X +Y +Z
	1, 4, 2, // -X +Y +Z
	0, 4, 3, // +X -Y +Z
	1, 3, 4, // -X -Y +Z
	0, 5, 2, // +X +Y -Z
	1, 2, 5, // -X +Y -Z
	0, 3, 5, // +X -Y -Z
	1, 5, 3, // -X -Y -Z
}
