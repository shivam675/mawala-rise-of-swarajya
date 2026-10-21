class_name Art
extends RefCounted

static func material(color: Color, texture: Texture2D = null) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	if texture:
		m.albedo_texture = texture
		m.uv1_triplanar = true
		m.uv1_world_triplanar = true
		m.uv1_scale = Vector3.ONE * 0.3
	return m

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.position = pos
	node.material_override = mat
	parent.add_child(node)
	return node

static func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, solid: bool = false) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	var node := mesh(parent, shape, pos, mat)
	if solid:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var hitbox := BoxShape3D.new()
		hitbox.size = size
		col.shape = hitbox
		body.add_child(col)
		node.add_child(body)
	return node

static func cylinder(parent: Node3D, pos: Vector3, bottom: float, top: float, height: float, mat: Material, segments: int = 16) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.bottom_radius = bottom
	shape.top_radius = top
	shape.height = height
	shape.radial_segments = segments
	return mesh(parent, shape, pos, mat)

static func sphere(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 12
	shape.rings = 6
	var node := mesh(parent, shape, pos, mat)
	node.scale = size
	return node

static func label(parent: Node3D, text: String, pos: Vector3) -> Label3D:
	var node := Label3D.new()
	node.text = text
	node.position = pos
	node.font_size = 36
	node.pixel_size = 0.009
	node.modulate = Color("f0d9ae")
	node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.no_depth_test = false
	node.outline_size = 8
	node.visibility_range_end = 17
	parent.add_child(node)
	return node
