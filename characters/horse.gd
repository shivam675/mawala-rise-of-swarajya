extends Node3D

const A = preload("res://art/build.gd")
var legs: Array[Node3D] = []
var phase: float = 0

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
	A.sphere(self,Vector3(0,1.10,0.94),Vector3(0.16,0.82,0.16),dark).rotation.x = -0.4
	A.box(self,Vector3(0,1.74,0.02),Vector3(0.73,0.12,0.64),saddle)
	A.box(self,Vector3(0,1.82,0.30),Vector3(0.60,0.18,0.08),dark)
	for x in [-0.27,0.27]:
		for z in [-0.54,0.55]:
			var leg := Node3D.new()
			leg.position = Vector3(x,1.18,z)
			add_child(leg)
			A.cylinder(leg,Vector3(0,-0.26,0),0.07,0.11,0.56,coat)
			A.cylinder(leg,Vector3(0,-0.74,0.025),0.045,0.065,0.43,coat)
			A.box(leg,Vector3(0,-1.10,-0.025),Vector3(0.15,0.17,0.21),dark)
			legs.append(leg)

func animate(delta: float, speed: float) -> void:
	phase += delta*(4+speed)
	for i in legs.size():
		legs[i].rotation.x = sin(phase+(PI if i in [0,3] else 0.0))*minf(speed/10,0.65)
	position.y = sin(phase*2)*minf(speed/180,0.065)
