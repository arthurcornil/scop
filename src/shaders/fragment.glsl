#version 330 core
in vec4 pos;
out vec4 FragColor;

void main()
{
	vec3 normal = normalize(cross(dFdx(pos.xyz), dFdy(pos.xyz)));
	vec3 lightDir = normalize(-pos.xyz);
	float shade = max(dot(normal, lightDir), 0.0);
	float ambient = 0.1;
	float grey = ambient + (1.0 - ambient) * shade;

	FragColor = vec4(grey, grey, grey, 1.0f);
}
