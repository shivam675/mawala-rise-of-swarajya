extends Node3D

const A = preload("res://art/build.gd")
var legs: Array[Node3D] = []
var phase: float = 0
var knees: Array[Node3D] = []
var tail: Node3D
var gait_speed: float = 0

func _ready() -> void:
	var coat := A.material(Color("63422e"))
	var dark := A.material(Color("241f1c"))
	var saddle := A.material(Color("7e3420"))
	A.sphere(self,Vector3(0,1.32,0),Vector3(0.77,0.91,1.65),coat)
	A.sphere(self,Vector3(0,1.65,-0.66),Vector3(0.52,1.05,0.63),coat).rotation.x = 0.38
	A.sphere(self,Vector3(0,2.10,-0.91),Vector3(0.41,0.55,0.65),coat).rotation.x = -0.35
	A.sphere(self,Vector3(0,1.93,-1.21),Vector3(0.35,0.29,0.42),coat)
	for side in [-1,1]:
		A.cylinder(self,Vector3(side*0.13,2.40,-0.85),0.075,0.01,0.24,coat)
		A.sphere(self,Vector3(side*0.205,2.13,-1.01),Vector3(0.04,0.05,0.05),dark)
	A.sphere(self,Vector3(0,1.85,-0.40),Vector3(0.13,0.84,0.4),dark).rotation.x = 0.32
	tail = Node3D.new()
	tail.position = Vector3(0,1.43,0.78)
	add_child(tail)
	A.sphere(tail,Vector3(0,-0.33,0.16),Vector3(0.16,0.82,0.16),dark).rotation.x = -0.4
	A.box(self,Vector3(0,1.74,0.02),Vector3(0.73,0.12,0.64),saddle)
	A.box(self,Vector3(0,1.82,0.30),Vector3(0.60,0.18,0.08),dark)
	for x in [-0.27,0.27]:
		for z in [-0.54,0.55]:
			var leg := Node3D.new()
			leg.position = Vector3(x,1.18,z)
			add_child(leg)
			A.cylinder(leg,Vector3(0,-0.26,0),0.07,0.11,0.56,coat)
			var knee := Node3D.new()
			knee.position.y = -0.54
			leg.add_child(knee)
			knees.append(knee)
			A.sphere(leg,Vector3(0,-0.54,0),Vector3(0.15,0.16,0.15),coat)
			A.cylinder(knee,Vector3(0,-0.20,0.025),0.045,0.065,0.43,coat)
			A.box(knee,Vector3(0,-0.56,-0.025),Vector3(0.15,0.17,0.21),dark)
			legs.append(leg)

# shortcut: procedural gaits do not plant hooves on slopes; use a skinned rig with foot IK for uneven terrain.
func animate(delta: float, speed: float) -> void:
	gait_speed = lerpf(gait_speed,maxf(speed,0),1.0-exp(-8.0*delta))
	phase += delta*(1.0+gait_speed*0.85)
	var stride := clampf(gait_speed/9.0,0.0,1.0)
	var gallop := smoothstep(10.0,16.0,gait_speed)
	var walk_phases := [0.0, PI, PI*1.5, PI*0.5]
	var gallop_phases := [0.0, 1.7, 0.45, 2.15]
	for i in legs.size():
		var step_phase: float = phase+lerpf(walk_phases[i],gallop_phases[i],gallop)
		legs[i].rotation.x = sin(step_phase)*stride*lerpf(0.42,0.72,gallop)
		knees[i].rotation.x = maxf(0,sin(step_phase-0.7))*stride*(0.85 if i%2==0 else -0.65)
	position.y = absf(sin(phase))*stride*lerpf(0.035,0.10,gallop)
	rotation.x = sin(phase+0.5)*stride*gallop*0.035
	tail.rotation.z = sin(phase*0.55)*0.12
	tail.rotation.x = -stride*0.18
