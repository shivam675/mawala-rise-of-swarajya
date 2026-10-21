shader_type spatial;
render_mode cull_disabled;
void vertex(){
	VERTEX.z += sin(UV.x*6.0-TIME*3.8)*UV.x*0.28;
	VERTEX.y += sin(UV.x*4.0-TIME*2.2)*UV.x*0.14;
}
void fragment(){
	ALBEDO = vec3(0.87,0.24,0.035)*(0.85+0.15*sin(UV.x*24.0));
	ROUGHNESS = 1.0;
}
