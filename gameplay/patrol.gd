extends CharacterBody3D

const Visual = preload("res://characters/warrior_visual.gd")
var game: Node
var visual: Node3D
var health: int = 100
var alert: float = 0
var state: String = "PATROL"
var destination: Vector3
var origin: Vector3
var direction: int = 1
var attack_timer: float = 0
var facing: float = 0

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = 0.5
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.85
	collision.shape = capsule
	collision.position.y = 0.94
	add_child(collision)
	visual = Visual.new()
	add_child(visual)
	origin = position
	destination = origin+Vector3(5,0,0)

func can_see_player() -> bool:
	var player = game.player
	var offset: Vector3 = player.global_position-global_position
	var detection_range: float = 7 if player.crouched else (23 if player.mounted else 15)
	if offset.length()>detection_range:
		return false
	var forward := Vector3(-sin(facing),0,-cos(facing))
	if forward.dot(offset.normalized())<0.62:
		return false
	var ray := PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*1.6,player.global_position+Vector3.UP*1.0,1)
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()

func _physics_process(delta: float) -> void:
	if not game.playing or game.interface.modal or health<=0:
		return
	attack_timer = maxf(0,attack_timer-delta)
	var seen := can_see_player()
	alert = clampf(alert+delta*(1.3 if seen else -0.48),0,1)
	if alert>=1:
		state = "CHASE"
	if state == "CHASE" and alert<=0:
		state = "PATROL"
	var target: Vector3 = game.player.global_position if state=="CHASE" else destination
	var offset := target-global_position
	offset.y = 0
	var speed: float = 4.8 if state=="CHASE" else 1.6
	if offset.length()<1.8 and state=="CHASE":
		speed = 0
		if attack_timer<=0:
			attack_timer = 1.1
			visual.attack_time = 0.42
			game.player.take_damage(14)
	elif offset.length()<0.8:
		direction *= -1
		destination = origin+Vector3(direction*5,0,0)
	var move := offset.normalized()*speed
	velocity.x = move.x
	velocity.z = move.z
	if not is_on_floor():
		velocity.y -= delta*19
	move_and_slide()
	if offset.length()>0.2:
		facing = lerp_angle(facing,atan2(-offset.x,-offset.z),delta*7)
	visual.rotation.y = facing
	visual.animate(delta,speed,is_on_floor(),false,false,false)

func take_damage(amount: int) -> void:
	if health<=0:
		return
	health = maxi(0,health-amount)
	alert = 1
	state = "CHASE"
	if health<=0:
		state = "DEFEATED"
		alert = 0
		visual.rotation.z = PI/2
		visual.position.y = 0.3
		collision_layer = 0
