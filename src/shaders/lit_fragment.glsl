#version 330 core
in vec3 fragPos;
in vec3 normal;
in vec2 TexCoord;
out vec4 FragColor;

uniform vec4 light_pos;
uniform sampler2D u_texture;

void main()
{
	vec3 n = normalize(normal);
	vec3 lightPos = vec3(light_pos.xyz);
	vec3 lightDir = normalize(lightPos - fragPos);
	float shade = max(dot(n, lightDir), 0.0);
	float ambient = 0.4;
	float grey = ambient + (1.0 - ambient) * shade;

	vec4 texColor = texture(u_texture, TexCoord);
	FragColor = texColor * vec4(grey, grey, grey, 1.0f);
}
