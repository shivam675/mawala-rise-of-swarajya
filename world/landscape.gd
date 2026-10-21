extends Node3D

const A = preload("res://art/build.gd")
var sun: DirectionalLight3D
var vegetation: Array[GeometryInstance3D] = []
var rng := RandomNumberGenerator.new()
var stone: StandardMaterial3D
var wood: StandardMaterial3D
var plaster: StandardMaterial3D
var roof: StandardMaterial3D
var terrain_material: ShaderMaterial
var landmark: Vector3 = Vector3(0,35,-84)

func path_x(z: float) -> float:
	return 12.0*sin(z*0.035)

func height_at(x: float, z: float) -> float:
	var center: float = 15+clampf((42-z)/150,0,1)*20
	var width: float = 8+24*smoothstep(10,34,z)+28*(1-smoothstep(-86,-70,z))
	var distance: float = maxf(0,absf(x-path_x(z))-width)
	var drop: float = pow(distance,0.94)*0.95
	var end_drop: float = maxf(0,z-65)*0.7+maxf(0,-142-z)*0.9
	var noise: float = (sin(x*0.14+z*0.07)*cos(z*0.12)*1.4+sin(x*0.39+z*0.23)*0.35)*smoothstep(4,15,absf(x-path_x(z)))
	return maxf(-32,center-drop-end_drop+noise)

func ground(x: float, z: float, offset: float = 0) -> Vector3:
	return Vector3(x,height_at(x,z)+offset,z)

func _ready() -> void:
	rng.seed = 1646
	stone = A.material(Color("827a6c"),load("res://art/textures/rock_face_03.jpg"))
	stone.normal_enabled = true
	stone.normal_texture = load("res://art/textures/rock_normal.jpg")
	stone.normal_scale = 0.65
	stone.roughness_texture = load("res://art/textures/rock_roughness.jpg")
	wood = A.material(Color("a29380"),load("res://art/textures/wood_color.jpg"))
	wood.normal_enabled = true
	wood.normal_texture = load("res://art/textures/wood_normal.jpg")
	wood.normal_scale = 0.5
	plaster = A.material(Color("c7b08e"),load("res://art/textures/plaster_color.jpg"))
	plaster.normal_enabled = true
	plaster.normal_texture = load("res://art/textures/plaster_normal.jpg")
	plaster.normal_scale = 0.5
	roof = A.material(Color("6f3c2b"))
	terrain_material = ShaderMaterial.new()
	terrain_material.shader = load("res://art/terrain.gdshader")
	terrain_material.set_shader_parameter("ground_tex",load("res://art/textures/sparse_grass.jpg"))
	terrain_material.set_shader_parameter("rock_tex",load("res://art/textures/rock_face_03.jpg"))
	terrain_material.set_shader_parameter("rock_roughness",load("res://art/textures/rock_roughness.jpg"))
	lighting()
	terrain()
	mountains()
	fort()
	village()
	foliage()
	water()

func lighting() -> void:
	var environment := Environment.new()
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = load("res://art/sky.gdshader")
	sky.sky_material = sky_material
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("a9a9bc")
	environment.ambient_light_energy = 0.42
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("b39c8c")
	environment.fog_light_energy = 0.75
	environment.fog_density = 0.0018
	environment.fog_sky_affect = 0.25
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-17,150,0)
	sun.light_color = Color("ffd09a")
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 150
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	add_child(sun)

func terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)
	for z in range(-166,92,3):
		for x in range(-132,132,3):
			var a := ground(x,z)
			var b := ground(x+3,z)
			var c := ground(x,z+3)
			var d := ground(x+3,z+3)
			for vertex in [a,b,c,b,d,c]:
				st.set_uv(Vector2(vertex.x,vertex.z)*0.2)
				st.add_vertex(vertex)
	st.generate_normals()
	st.index()
	var shape: ArrayMesh = st.commit()
	var terrain_node := A.mesh(self,shape,Vector3.ZERO,terrain_material)
	terrain_node.create_trimesh_collision()

func mountains() -> void:
	for layer in 3:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var radius: float = 230+layer*140
		var peaks := PackedVector3Array()
		for i in 81:
			var angle: float = i*TAU/80
			var h: float = 22+sin(i*0.51+layer*2)*22+sin(i*1.3)*9+rng.randf_range(-4,9)
			peaks.append(Vector3(cos(angle)*radius,h+layer*15,sin(angle)*radius-70))
		for i in 80:
			for v in [peaks[i],peaks[i+1],Vector3(peaks[i].x,-50,peaks[i].z),peaks[i+1],Vector3(peaks[i+1].x,-50,peaks[i+1].z),Vector3(peaks[i].x,-50,peaks[i].z)]:
				st.add_vertex(v)
		st.generate_normals()
		var mat := A.material([Color("62645f"),Color("7e7a78"),Color("96908b")][layer])
		A.mesh(self,st.commit(),Vector3.ZERO,mat).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Broad secondary mesas give the valley depth rather than an empty horizon.
	for i in 17:
		var x: float = rng.randf_range(105,240)*(1 if i%2==0 else -1)
		var z: float = rng.randf_range(-220,80)
		var mesa := A.cylinder(self,Vector3(x,-16,z),rng.randf_range(35,60),rng.randf_range(8,20),rng.randf_range(30,68),stone,12)
		mesa.rotation.y = rng.randf()*TAU

func battlement(pos: Vector3, length: float, angle: float = 0) -> void:
	var wall := Node3D.new()
	add_child(wall)
	wall.position = pos
	wall.rotation.y = angle
	A.box(wall,Vector3(0,4,0),Vector3(length,8,2.6),stone,true)
	A.box(wall,Vector3(0,7.5,0),Vector3(length+0.3,0.5,3),stone)
	for i in int(length/2.1):
		A.box(wall,Vector3(-length/2+1+i*2.1,8.5,0),Vector3(1.1,1.5,2.5),stone)
	for i in int(length/3):
		A.box(wall,Vector3(-length/2+1.5+i*3,5.3,1.32),Vector3(0.15,1.2,0.03),wood)

func tower(x: float,z: float,radius: float,h: float) -> void:
	var base := ground(x,z)
	var body := A.cylinder(self,base+Vector3(0,h/2,0),radius*1.12,radius,h,stone,24)
	body.create_convex_collision()
	A.cylinder(self,base+Vector3(0,h-0.3,0),radius+0.30,radius+0.30,0.55,stone,24)
	for i in 14:
		var angle: float = i*TAU/14
		var merlon := A.box(self,base+Vector3(sin(angle)*radius,h+0.55,cos(angle)*radius),Vector3(0.95,1.65,0.85),stone)
		merlon.rotation.y = angle
	for i in 8:
		var angle: float = i*TAU/8
		var slit := A.box(self,base+Vector3(sin(angle)*(radius+0.12),h*0.65,cos(angle)*(radius+0.12)),Vector3(0.13,1.25,0.07),wood)
		slit.rotation.y = angle

func flag(pos: Vector3, size: float = 1) -> void:
	A.cylinder(self,pos+Vector3(0,2.8*size,0),0.055,0.04,5.6*size,wood)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 10:
		var u: float = i/10.0
		var v: float = (i+1)/10.0
		for point in [Vector2(u,0),Vector2(v,0),Vector2(u,1),Vector2(v,0),Vector2(v,1),Vector2(u,1)]:
			st.set_uv(point)
			var notch: float = 0.55*absf(point.y-0.5)*2
			st.add_vertex(Vector3(point.x*(2.5-notch)*size,(5.2-point.y*1.3)*size,0))
	st.generate_normals()
	var mat := ShaderMaterial.new()
	mat.shader = load("res://art/banner.gdshader")
	A.mesh(self,st.commit(),pos,mat)

func fort() -> void:
	var front_y: float = height_at(0,-84)
	battlement(Vector3(-18,front_y,-84),23)
	battlement(Vector3(17,front_y,-84),24)
	battlement(ground(-28,-108),48,PI/2)
	battlement(ground(28,-108),48,PI/2)
	battlement(ground(0,-132),56)
	for x in [-27.0,27.0]:
		tower(x,-84,4.8,10)
		tower(x,-131,4.8,11)
	for x in [-6.0,6.0]:
		tower(x,-84,3.8,12)
	# Segmental arch leaves a real traversable gateway through the wall.
	for i in 12:
		var angle: float = i*PI/11
		var block := A.box(self,Vector3(cos(angle)*3.7,front_y+5.0+sin(angle)*3.7,-84),Vector3(1.1,1.5,3.2),stone,true)
		block.rotation.z = angle-PI/2
	A.box(self,Vector3(0,front_y+10.4,-84),Vector3(6.5,3.2,2.6),stone)
	var keep_y: float = height_at(8,-119)
	A.box(self,Vector3(8,keep_y+7.5,-119),Vector3(17,15,13),stone,true)
	A.box(self,Vector3(8,keep_y+15,-119),Vector3(18,0.65,14),stone)
	for i in 9:
		for z in [-126.0,-112.0]:
			A.box(self,Vector3(i*2.0,keep_y+15.8,z),Vector3(1.1,1.5,1),stone)
	for x in [0.0,17.0]:
		for z in range(-124,-112,2):
			A.box(self,Vector3(x,keep_y+15.8,z),Vector3(1,1.5,1),stone)
	for x in [3.0,8.0,13.0]:
		A.box(self,Vector3(x,keep_y+9,-112.45),Vector3(0.8,1.8,0.05),wood)
	flag(Vector3(8,keep_y+15.6,-119),1.6)
	flag(ground(-27,-84)+Vector3(0,11,0),0.9)
	flag(ground(6,-84)+Vector3(0,13,0),1.1)
	flag(ground(-25,-130)+Vector3(0,12,0),0.8)
	# Original cistern, sheltered store, lookout and a few courtyard props.
	A.box(self,ground(-15,-114,0.2),Vector3(12,0.5,9),stone,true)
	var water_mat := A.material(Color("435c58"))
	water_mat.roughness = 0.2
	A.box(self,ground(-15,-114,0.5),Vector3(10,0.05,7),water_mat)
	house(-16,-96,0.8)
	for i in 7:
		A.box(self,ground(18+i%2,-94-i*1.8,0.5),Vector3(1,1,1),wood,true)
	flag(ground(path_x(-27)+4,-27),0.75)
	A.cylinder(self,ground(path_x(-27)+4,-27,-0.3),4.4,4.4,0.8,stone,24)

func house(x: float,z: float,s: float = 1) -> void:
	var house_node := Node3D.new()
	add_child(house_node)
	house_node.position = ground(x,z)
	house_node.scale = Vector3.ONE*s
	A.box(house_node,Vector3(0,1.8,0),Vector3(6,3.6,5),plaster,true)
	A.box(house_node,Vector3(0,0.25,0),Vector3(6.5,0.5,5.5),stone,true)
	A.box(house_node,Vector3(0,1.25,2.52),Vector3(1.2,2.5,0.1),wood)
	for side in [-1,1]:
		A.box(house_node,Vector3(side*1.85,2,2.53),Vector3(0.8,0.95,0.08),wood)
		var slope := A.box(house_node,Vector3(side*1.65,4.0,0),Vector3(3.8,0.18,6.2),roof)
		slope.rotation.z = side*-0.40
		for i in 11:
			var tile := A.box(house_node,Vector3(side*1.65,4.13,-2.8+i*0.55),Vector3(3.85,0.09,0.055),A.material(Color("8b5136")))
			tile.rotation.z = side*-0.4
		A.cylinder(house_node,Vector3(side*2.9,1.8,3.25),0.09,0.09,3.6,wood)
	A.box(house_node,Vector3(0,0.12,3.0),Vector3(6.4,0.3,1.5),stone,true)

func village() -> void:
	for p in [Vector2(-14,43),Vector2(-22,56),Vector2(25,48),Vector2(23,29),Vector2(-15,22),Vector2(6,62)]:
		house(p.x,p.y,rng.randf_range(0.85,1.15))
	flag(ground(6,40),0.8)
	for i in 3:
		var x: float = -4-i*3.2
		A.box(self,ground(x,52,1.0),Vector3(2.5,0.18,1.2),wood,true)
		for side in [-1,1]:
			A.cylinder(self,ground(x+side*1.1,52,1.5),0.06,0.06,3,wood)
		A.box(self,ground(x,52,3.0),Vector3(2.8,0.08,2.3),A.material(Color("a56e40")))
		for n in 3:
			A.sphere(self,ground(x-0.7+n*0.7,52,1.25),Vector3(0.45,0.35,0.4),A.material(Color("b18d56")))
	# Farming terraces, a workshop anvil, stable fence and roadside markers.
	for i in 9:
		A.box(self,ground(-32+i*1.2,35,0.1),Vector3(0.5,0.2,8),A.material(Color("584b30")))
	A.box(self,ground(-17,18,0.7),Vector3(0.8,1.4,0.7),stone,true)
	A.box(self,ground(-17,18,1.45),Vector3(1.3,0.22,0.6),A.material(Color("4b4b45")))
	for i in 8:
		A.cylinder(self,ground(16,15+i*1.4,0.7),0.07,0.07,1.4,wood)
	A.box(self,ground(16,20,1.1),Vector3(0.10,0.08,12),wood)
	for z in [8.0,-12.0,-48.0,-68.0]:
		A.cylinder(self,ground(path_x(z)+3.9,z,0.5),0.24,0.17,1.0,stone,7)

func foliage() -> void:
	var grass := SurfaceTool.new()
	grass.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 6:
		var angle: float = i*2.4
		var height: float = rng.randf_range(0.3,0.7)
		for v in [Vector2(-0.025,0),Vector2(0.025,0),Vector2(0.06,height)]:
			grass.set_uv(Vector2(v.x+0.5,v.y/height))
			grass.add_vertex(Vector3(cos(angle)*v.x+sin(angle)*0.12,v.y,sin(angle)*v.x+cos(angle)*0.12))
	grass.generate_normals()
	var grass_mat := ShaderMaterial.new()
	grass_mat.shader = load("res://art/foliage.gdshader")
	var blades := MultiMesh.new()
	blades.transform_format = MultiMesh.TRANSFORM_3D
	blades.mesh = grass.commit()
	blades.instance_count = 14000
	for i in blades.instance_count:
		var z: float = rng.randf_range(-145,79)
		var x: float = path_x(z)+rng.randf_range(-70,70)
		if absf(x-path_x(z))<3 or (z<-79 and absf(x)<33):
			x += 7
		var scale_factor: float = rng.randf_range(0.45,1.2)
		blades.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*scale_factor),ground(x,z,-0.04)))
	var grass_node := MultiMeshInstance3D.new()
	grass_node.multimesh = blades
	grass_node.material_override = grass_mat
	grass_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	grass_node.visibility_range_end = 95
	add_child(grass_node)
	vegetation.append(grass_node)
	# Shared compound tree mesh: rounded canopies, branched trunks; two draw calls.
	var trunk_st := SurfaceTool.new()
	trunk_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var trunk := CylinderMesh.new()
	trunk.height = 4.0
	trunk.bottom_radius = 0.22
	trunk.top_radius = 0.07
	trunk.radial_segments = 7
	trunk_st.append_from(trunk,0,Transform3D(Basis(),Vector3(0,2,0)))
	var leaf_st := SurfaceTool.new()
	leaf_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var crown := SphereMesh.new()
	crown.radius = 1
	crown.height = 2
	crown.radial_segments = 12
	crown.rings = 8
	for i in 23:
		var angle: float = i*2.4
		var radius: float = rng.randf_range(0.4,2.2)
		var origin := Vector3(sin(angle)*radius,3.5+rng.randf_range(0,2.0),cos(angle)*radius)
		leaf_st.append_from(crown,0,Transform3D(Basis().scaled(Vector3(0.9,0.70,1.0)),origin))
	var transforms: Array[Transform3D] = []
	for i in 240:
		var z: float = rng.randf_range(-142,80)
		var x: float = path_x(z)+rng.randf_range(12,110)*(1 if i%2==0 else -1)
		if z < -77 and absf(x)<40:
			continue
		var s: float = rng.randf_range(0.7,1.55)
		transforms.append(Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*s),ground(x,z)))
	for pair in [[trunk_st.commit(),wood],[leaf_st.commit(),A.material(Color("394526"))]]:
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = pair[0]
		multimesh.instance_count = transforms.size()
		for i in transforms.size():
			multimesh.set_instance_transform(i,transforms[i])
		var node := MultiMeshInstance3D.new()
		node.multimesh = multimesh
		node.material_override = pair[1]
		node.visibility_range_end = 210
		add_child(node)
		vegetation.append(node)
	var rocks := MultiMesh.new()
	rocks.transform_format = MultiMesh.TRANSFORM_3D
	var rock_shape := SphereMesh.new()
	rock_shape.radius = 1
	rock_shape.height = 2
	rock_shape.radial_segments = 18
	rock_shape.rings = 10
	var rock_arrays: Array = rock_shape.surface_get_arrays(0)
	var vertices: PackedVector3Array = rock_arrays[Mesh.ARRAY_VERTEX]
	var rock_noise := FastNoiseLite.new()
	rock_noise.seed = 181
	rock_noise.frequency = 2.3
	for i in vertices.size():
		var v: Vector3 = vertices[i]
		vertices[i] = v*(1+rock_noise.get_noise_3dv(v)*0.45)
	rock_arrays[Mesh.ARRAY_VERTEX] = vertices
	var raw_rock := ArrayMesh.new()
	raw_rock.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,rock_arrays)
	var rock_surface := SurfaceTool.new()
	rock_surface.create_from(raw_rock,0)
	rock_surface.generate_normals()
	rocks.mesh = rock_surface.commit()
	rocks.instance_count = 270
	for i in rocks.instance_count:
		var z: float = rng.randf_range(-150,82)
		var x: float = path_x(z)+rng.randf_range(6.5,90)*(1 if i%2==0 else -1)
		var s := Vector3(rng.randf_range(0.4,2.3),rng.randf_range(0.3,1.5),rng.randf_range(0.4,1.8))
		rocks.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(s),ground(x,z,-0.2)))
		if absf(x-path_x(z))<24:
			var body := StaticBody3D.new()
			var collision := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = s*1.35
			collision.shape = shape
			body.position = ground(x,z,-0.2)
			body.add_child(collision)
			add_child(body)
	var rock_node := MultiMeshInstance3D.new()
	rock_node.multimesh = rocks
	rock_node.material_override = stone
	add_child(rock_node)

func water() -> void:
	var material := A.material(Color("788e88"))
	material.metallic = 0.25
	material.roughness = 0.27
	A.box(self,Vector3(0,-27,0),Vector3(1100,0.1,1100),material).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
