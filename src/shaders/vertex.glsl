#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNorm;
layout (location = 2) in vec2 aTexCoord;

out vec3 fragPos;
out vec3 normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
	vec4 viewPos = view * model * vec4(aPos, 1.0);
	gl_Position = projection * viewPos;
	fragPos = viewPos.xyz;
	normal = mat3(view * model) * aNorm;
}
