shader_type sky;
render_mode use_debanding;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void sky(){
	vec3 d=normalize(EYEDIR);
	vec3 sun=normalize(vec3(0.49,0.18,-0.85));
	float height=max(d.y,0.0);
	vec3 color=mix(vec3(0.76,0.48,0.31),vec3(0.22,0.27,0.36),pow(height,0.45));
	float alignment=max(dot(d,sun),0.0);
	color+=vec3(0.64,0.26,0.065)*pow(alignment,14.0)*0.5;
	color+=vec3(1.8,1.45,0.82)*smoothstep(0.99955,0.9998,alignment);
	vec2 p=d.xz/max(0.12,d.y+0.2)*2.5;
	float cloud=noise(p)*0.55+noise(p*2.4)*0.28+noise(p*5.0)*0.17;
	float cover=smoothstep(0.49,0.72,cloud)*smoothstep(0.015,0.15,height);
	color=mix(color,vec3(0.35,0.32,0.34)+vec3(0.40,0.19,0.09)*pow(alignment,3.0),cover*0.7);
	COLOR=color;
}
