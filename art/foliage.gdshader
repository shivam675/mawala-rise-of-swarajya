shader_type spatial;
render_mode cull_disabled;
void vertex(){
	vec3 p = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	VERTEX.x += sin(TIME*1.7+p.x*0.6+p.z*0.4)*0.10*UV.y;
}
void fragment(){
	ALBEDO = mix(vec3(0.12,0.16,0.045),vec3(0.37,0.36,0.13),UV.y);
	ROUGHNESS = 1.0;
}
