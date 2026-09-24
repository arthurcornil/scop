#version 330 core
in vec3 fragPos;
in vec3 normal;
out vec4 FragColor;

uniform vec4 light_pos;

void main()
{
	vec3 n = normalize(normal);
	vec3 lightPos = vec3(light_pos.xyz);
	vec3 lightDir = normalize(lightPos - fragPos);
	float shade = max(dot(n, lightDir), 0.0);
	float ambient = 0.4;
	float grey = ambient + (1.0 - ambient) * shade;

	FragColor = vec4(grey, grey, grey, 1.0f);
}
