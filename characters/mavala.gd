extends CharacterBody3D

const Visual = preload("res://characters/warrior_visual.gd")
const Horse = preload("res://characters/horse.gd")
var game: Node
var visual: Node3D
var horse: Node3D
var pivot: Node3D
var arm: SpringArm3D
var camera: Camera3D
var collider: CollisionShape3D
var mounted: bool = false
var crouched: bool = false
var blocking: bool = false
var health: int = 100
var sensitivity: float = 0.0028
var shoulder: bool = false
var attack_cooldown: float = 0
var dodge_time: float = 0
var dodge_direction := Vector3.ZERO
var facing: float = 0
var pitch: float = -0.08
var yaw: float = 0.12
var distance: float = 8.3

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.55
	floor_max_angle = deg_to_rad(48)
	collider = CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.30
	capsule.height = 1.85
	collider.shape = capsule
	collider.position.y = 0.94
	add_child(collider)
	visual = Visual.new()
	add_child(visual)
	horse = Horse.new()
	add_child(horse)
	horse.hide()
	pivot = Node3D.new()
	add_child(pivot)
	pivot.position.y = 1.65
	arm = SpringArm3D.new()
	arm.spring_length = distance
	arm.margin = 0.2
	arm.collision_mask = 1
	var sphere := SphereShape3D.new()
	sphere.radius = 0.22
	arm.shape = sphere
	arm.add_excluded_object(get_rid())
	pivot.add_child(arm)
	camera = Camera3D.new()
	camera.fov = 65
	camera.far = 1300
	arm.add_child(camera)
	camera.current = true
	pivot.rotation = Vector3(pitch,yaw,0)

func _unhandled_input(event: InputEvent) -> void:
	if not game.playing or game.interface.modal:
		return
	if event is InputEventMouseMotion and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED or Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)):
		yaw -= event.relative.x*sensitivity
		pitch = clampf(pitch-event.relative.y*sensitivity,-0.7,0.55)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(3.5,distance-0.6)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(13,distance+0.6)
	if event.is_action_pressed("shoulder"):
		shoulder = not shoulder
	if event.is_action_pressed("equip"):
		visual.equipped = not visual.equipped
	if event.is_action_pressed("crouch") and not mounted:
		if crouched:
			var query := PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*0.8,global_position+Vector3.UP*1.9,1)
			if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
				return
		crouched = not crouched
		collider.shape.height = 1.15 if crouched else 1.85
		collider.position.y = 0.60 if crouched else 0.94
	if event.is_action_pressed("attack") and attack_cooldown<=0 and not mounted and visual.equipped:
		attack_cooldown = 0.5
		visual.attack_time = 0.42
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var offset: Vector3 = enemy.global_position-global_position
			if offset.length()<2.6 and Vector3(-sin(facing),0,-cos(facing)).dot(offset.normalized())>0.1:
				enemy.take_damage(34)
	if event.is_action_pressed("dodge") and dodge_time<=0 and not mounted:
		dodge_time = 0.38
		var direction := Input.get_vector("left","right","forward","back")
		dodge_direction = (Basis(Vector3.UP,yaw)*Vector3(direction.x,0,direction.y)).normalized()
		if dodge_direction == Vector3.ZERO:
			dodge_direction = Vector3(-sin(facing),0,-cos(facing))

func _physics_process(delta: float) -> void:
	if not game.playing or game.interface.modal:
		visual.animate(delta,0,true,crouched,mounted,false)
		return
	attack_cooldown = maxf(0,attack_cooldown-delta)
	dodge_time = maxf(0,dodge_time-delta)
	var direction := Vector3.ZERO
	var speed: float = 0
	if game.playing and not game.interface.modal:
		var input := Input.get_vector("left","right","forward","back")
		direction = (Basis(Vector3.UP,yaw)*Vector3(input.x,0,input.y)).normalized()
		blocking = Input.is_action_pressed("block") and not mounted
		speed = (17.0 if Input.is_action_pressed("sprint") else 9.0) if mounted else (7.0 if Input.is_action_pressed("sprint") else 4.3)
		if crouched:
			speed = 2.0
		if blocking:
			speed = 1.8
		if Input.is_action_just_pressed("jump") and is_on_floor() and not mounted:
			velocity.y = 6.5
	else:
		blocking = false
	var desired := direction*speed
	if dodge_time>0:
		desired = dodge_direction*10
	velocity.x = move_toward(velocity.x,desired.x,delta*(12 if mounted else 28))
	velocity.z = move_toward(velocity.z,desired.z,delta*(12 if mounted else 28))
	if not is_on_floor():
		velocity.y -= 19*delta
	elif velocity.y<0:
		velocity.y = 0
	move_and_slide()
	var horizontal_speed := Vector2(velocity.x,velocity.z).length()
	if direction.length()>0.1:
		facing = lerp_angle(facing,atan2(-direction.x,-direction.z),delta*(5 if mounted else 12))
	visual.rotation.y = facing
	horse.rotation.y = facing
	visual.position.y = 1.04 if mounted else 0.0
	visual.animate(delta,horizontal_speed,is_on_floor(),crouched,mounted,blocking)
	horse.animate(delta,horizontal_speed)
	pivot.position.y = lerpf(pivot.position.y,2.7 if mounted else 1.65,delta*5)
	pivot.rotation = Vector3(pitch,yaw,0)
	arm.spring_length = lerpf(arm.spring_length,distance+(2.2 if mounted else 0),delta*4)
	arm.position.x = lerpf(arm.position.x,0.7 if shoulder else 0.0,delta*8)
	camera.fov = lerpf(camera.fov,72 if mounted and horizontal_speed>12 else 65,delta*3)
	if position.y < -19:
		game.recover_player()

func set_mounted(value: bool) -> void:
	mounted = value
	crouched = false
	horse.visible = value
	collider.shape.radius = 0.50 if value else 0.30
	collider.shape.height = 2.7 if value else 1.85
	collider.position.y = 1.36 if value else 0.94

func take_damage(amount: int) -> void:
	if dodge_time>0:
		return
	health = maxi(0,health-(int(ceil(amount*0.2)) if blocking else amount))
	if health<=0:
		game.recover_player()

func try_climb() -> bool:
	if mounted:
		return false
	var forward := Vector3(-sin(facing),0,-cos(facing))
	var front: Vector3 = global_position+forward*1.1
	var query := PhysicsRayQueryParameters3D.create(front+Vector3.UP*1.45,front+Vector3.UP*0.2,1)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or hit.normal.y<0.7:
		return false
	var top: Vector3 = hit.position
	if top.y-global_position.y<0.35:
		return false
	query = PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*2,top+Vector3.UP*1.8,1)
	if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
		return false
	global_position = top+Vector3.UP*0.1
	velocity = forward*1.5
	return true
