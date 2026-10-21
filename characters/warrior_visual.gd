extends Node3D

const A = preload("res://art/build.gd")
var limbs: Array[Node3D] = []
var joints: Array[Node3D] = []
var torso: Node3D
var sword: Node3D
var shield: Node3D
var time: float = 0
var attack_time: float = 0
var equipped: bool = true

func _ready() -> void:
	var ivory := A.material(Color("d1c1a0"))
	var saffron := A.material(Color("a5461d"))
	for cloth in [ivory, saffron]:
		cloth.normal_enabled = true
		cloth.normal_texture = load("res://art/textures/cloth_normal.jpg")
		cloth.normal_scale = 0.35
		cloth.uv1_scale = Vector3(3,3,3)
	var skin := A.material(Color("9c6945"))
	var leather := A.material(Color("342922"))
	var steel := A.material(Color("8b9695"))
	steel.metallic = 0.85
	steel.roughness = 0.3
	var gold := A.material(Color("b69757"))
	torso = Node3D.new()
	add_child(torso)
	A.cylinder(torso, Vector3(0,1.20,0), 0.28,0.23,0.55,ivory)
	A.cylinder(torso, Vector3(0,0.87,0), 0.39,0.245,0.40,ivory,24)
	for i in 16:
		var angle: float = i*TAU/16
		A.box(torso,Vector3(sin(angle)*0.315,0.86,cos(angle)*0.315),Vector3(0.015,0.34,0.018),A.material(Color("b0a082")))
	A.cylinder(torso,Vector3(0,1.01,0),0.282,0.282,0.12,saffron)
	var sash := A.box(torso,Vector3(-0.05,1.26,0.247),Vector3(0.10,0.55,0.035),saffron)
	sash.rotation.z = -0.42
	A.box(torso,Vector3(-0.24,0.72,0.09),Vector3(0.14,0.53,0.045),saffron).rotation.z = -0.18
	A.sphere(torso,Vector3(0,1.68,0),Vector3(0.34,0.42,0.32),skin)
	A.sphere(torso,Vector3(0,1.52,-0.03),Vector3(0.29,0.18,0.30),leather)
	A.sphere(torso,Vector3(0,1.65,-0.167),Vector3(0.18,0.045,0.045),leather)
	A.sphere(torso,Vector3(0,1.69,-0.175),Vector3(0.065,0.11,0.07),skin)
	for i in 5:
		var band := A.sphere(torso,Vector3(0,1.82+i*0.022,0.01),Vector3(0.40-i*0.025,0.17,0.38-i*0.022),saffron)
		band.rotation.z = (i-2)*0.10
	A.box(torso,Vector3(0.16,1.73,0.10),Vector3(0.085,0.32,0.045),saffron).rotation.z = -0.2
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.position = Vector3(side*0.14,0.80,0)
		add_child(leg)
		A.cylinder(leg,Vector3(0,-0.19,0),0.09,0.125,0.38,ivory)
		var knee := Node3D.new()
		knee.position.y = -0.38
		leg.add_child(knee)
		joints.append(knee)
		A.sphere(leg,Vector3(0,-0.37,0),Vector3(0.18,0.18,0.18),ivory)
		A.cylinder(knee,Vector3(0,-0.10,0),0.065,0.085,0.28,skin)
		A.sphere(knee,Vector3(0,-0.32,-0.065),Vector3(0.17,0.14,0.32),leather)
		limbs.append(leg)
	for side in [-1,1]:
		var arm := Node3D.new()
		arm.position = Vector3(side*0.29,1.42,0)
		torso.add_child(arm)
		A.cylinder(arm,Vector3(side*0.04,-0.12,0),0.09,0.12,0.29,ivory)
		var elbow := Node3D.new()
		elbow.position = Vector3(side*0.05,-0.27,0)
		arm.add_child(elbow)
		joints.append(elbow)
		A.cylinder(elbow,Vector3(0,-0.09,-0.025),0.06,0.08,0.25,skin)
		A.sphere(elbow,Vector3(0,-0.24,-0.035),Vector3(0.13,0.16,0.13),skin)
		limbs.append(arm)
	sword = Node3D.new()
	joints[3].add_child(sword)
	sword.position = Vector3(0,-0.24,-0.02)
	A.cylinder(sword,Vector3(0,0,0),0.035,0.035,0.19,leather)
	A.box(sword,Vector3(0,0.12,0),Vector3(0.23,0.035,0.055),gold)
	A.box(sword,Vector3(0,0.54,-0.06),Vector3(0.065,0.82,0.025),steel).rotation.x = -0.12
	shield = Node3D.new()
	torso.add_child(shield)
	shield.position = Vector3(0,1.25,0.28)
	var disk := A.cylinder(shield,Vector3.ZERO,0.32,0.32,0.075,leather,24)
	disk.rotation.x = PI/2
	for i in 4:
		A.sphere(shield,Vector3(sin(i*PI/2)*0.16,cos(i*PI/2)*0.16,0.06),Vector3(0.055,0.055,0.04),gold)
	A.sphere(shield,Vector3(0,0,0.055),Vector3(0.11,0.11,0.07),gold)

func animate(delta: float, speed: float, grounded: bool, crouched: bool, riding: bool, blocking: bool) -> void:
	time += delta*(1.5+speed*1.9)
	var stride: float = minf(speed/4.0,1.0)
	for i in 4:
		var target: float = sin(time + ((i%2) if i<2 else (1-i%2))*PI)*stride*(0.58 if i<2 else 0.42)
		if not grounded:
			target = -0.40 if i<2 else -0.75
		if riding:
			target = -1.0 if i<2 else -0.65
		limbs[i].rotation.x = lerp(limbs[i].rotation.x,target,minf(delta*14,1))
		var bend: float = maxf(0.0, sin(time+(i%2)*PI))*stride*0.95 if i<2 else -0.25-stride*0.55
		if riding:
			bend = 1.15 if i<2 else -0.65
		elif crouched and i<2:
			bend += 0.65
		joints[i].rotation.x = lerpf(joints[i].rotation.x,bend,1.0-exp(-14.0*delta))
		limbs[i].rotation.z = (0.35 if i==0 else -0.35) if riding and i<2 else 0.0
	torso.position.y = sin(time*2)*0.018*stride - (0.32 if crouched else 0.0)
	torso.rotation.x = 0.20 if crouched else minf(speed*0.012,0.1)
	torso.rotation.y = sin(time)*stride*0.045
	torso.scale.y = 1.0+sin(time*0.65)*0.004*(1.0-stride)
	attack_time = maxf(0,attack_time-delta)
	if attack_time > 0:
		limbs[3].rotation.x = -1.6 + sin((1-attack_time/0.42)*PI)*2.5
		limbs[3].rotation.z = -0.6
	else:
		limbs[3].rotation.z = 0
	shield.position = Vector3(-0.37,1.27,-0.27) if blocking else Vector3(0,1.25,0.28)
	sword.visible = equipped and not riding
