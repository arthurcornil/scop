#version 330 core
in vec3 fragPos;
in vec3 normal;
out vec4 FragColor;

void main()
{
	vec3 n = normalize(normal);
	vec3 lightDir = normalize(-fragPos);
	float shade = max(dot(n, lightDir), 0.0);
	float ambient = 0.1;
	float grey = ambient + (1.0 - ambient) * shade;

	FragColor = vec4(grey, grey, grey, 1.0f);
}
