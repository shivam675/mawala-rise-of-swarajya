shader_type spatial;
render_mode cull_back;
uniform sampler2D ground_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
varying vec3 world_pos;
varying vec3 world_normal;
void vertex(){
	world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	world_normal = normalize((MODEL_NORMAL_MATRIX * NORMAL));
}
void fragment(){
	vec2 uv = world_pos.xz * 0.21;
	vec3 grass = texture(ground_tex,uv).rgb * vec3(0.79,0.79,0.58);
	vec3 weights = pow(abs(world_normal), vec3(4.0));
	weights /= max(dot(weights,vec3(1.0)),0.001);
	vec3 rock = (texture(rock_tex,world_pos.zy*0.25).rgb*weights.x + texture(rock_tex,world_pos.xz*0.25).rgb*weights.y + texture(rock_tex,world_pos.xy*0.25).rgb*weights.z)*vec3(0.65,0.65,0.67);
	float slope = smoothstep(0.67,0.94,world_normal.y);
	vec3 color = mix(rock,grass,slope);
	float path_x = 12.0*sin(world_pos.z*0.035);
	float trail = 1.0-smoothstep(2.1,3.5,abs(world_pos.x-path_x));
	vec3 dust = texture(rock_tex,uv*1.4).rgb * vec3(1.08,0.9,0.66);
	color = mix(color,dust,trail*slope);
	float courtyard = step(-132.0,world_pos.z)*(1.0-step(-87.0,world_pos.z))*(1.0-step(26.0,abs(world_pos.x)));
	color = mix(color,texture(rock_tex,uv*0.7).rgb*0.65,courtyard);
	float variation = texture(ground_tex, world_pos.xz*0.018).r;
	ALBEDO = color * mix(0.82,1.12,variation);
	ROUGHNESS = mix(texture(rock_roughness,uv).r,0.96,slope);
}
