extends Node3D

const Landscape = preload("res://world/landscape.gd")
const Player = preload("res://characters/mavala.gd")
const Mission = preload("res://gameplay/mission.gd")
const Patrol = preload("res://gameplay/patrol.gd")
const Interface = preload("res://ui/interface.gd")
const Visual = preload("res://characters/warrior_visual.gd")
const Horse = preload("res://characters/horse.gd")
const A = preload("res://art/build.gd")

var world: Node3D
var player: CharacterBody3D
var mission: Node
var enemy: CharacterBody3D
var interface: CanvasLayer
var parked_horse: Node3D
var supplies: Node3D
var marker: MeshInstance3D
var ambient: AudioStreamPlayer
var npcs: Array[Dictionary] = []
var playing: bool = false
var quality: int = 2
var show_performance: bool = false
var dialogue: Dictionary
var elapsed: float = 0

func _ready() -> void:
	configure_input()
	dialogue = JSON.parse_string(FileAccess.get_file_as_string("res://localization/en.json"))
	world = Landscape.new()
	add_child(world)
	mission = Mission.new()
	mission.game = self
	add_child(mission)
	player = Player.new()
	player.game = self
	player.position = world.ground(world.path_x(8),8,0.3)
	add_child(player)
	parked_horse = Horse.new()
	parked_horse.position = world.ground(10,21,0.1)
	parked_horse.rotation.y = 0.15
	add_child(parked_horse)
	A.label(parked_horse,"BADAL",Vector3(0,2.9,0))
	create_npc("Keshav", "village elder", 10,34, "elder")
	create_npc("Jiva", "gate sentry", 0,-79, "guard")
	create_npc("Suryaji", "outpost keeper", -5,-99, "oath")
	create_npc("Bapu", "blacksmith", -17,19, "smith")
	create_npc("Gauri", "grain trader", -6,50, "trader")
	create_npc("Rama", "villager", 19,39, "villager",true)
	create_npc("Hari", "villager", 3,55, "villager",true)
	enemy = Patrol.new()
	enemy.game = self
	enemy.position = world.ground(world.path_x(-55),-55,1)
	add_child(enemy)
	A.label(enemy,"RIDGE PATROL",Vector3(0,2.5,0))
	supplies = Node3D.new()
	add_child(supplies)
	supplies.position = world.ground(-9,43)
	for i in 3:
		A.sphere(supplies,Vector3(i*0.45-0.45,0.35,0),Vector3(0.6,0.7,0.5),A.material(Color("ad976e")))
	A.box(supplies,Vector3(0,0.78,0),Vector3(0.55,0.20,0.4),A.material(Color("d4c8a8")))
	A.label(supplies,"OUTPOST SUPPLIES",Vector3(0,1.5,0))
	var marker_material := A.material(Color("e8ab62"))
	marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker = A.cylinder(self,Vector3.ZERO,0.18,0,0.6,marker_material,4)
	interface = Interface.new()
	interface.game = self
	add_child(interface)
	load_settings()
	apply_quality(quality,false)
	ambient = AudioStreamPlayer.new()
	ambient.stream = load("res://audio/valley.wav")
	ambient.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambient.stream.loop_end = int(ambient.stream.get_length()*ambient.stream.mix_rate)
	ambient.volume_db = -15
	add_child(ambient)

func configure_input() -> void:
	var keys := {"forward":KEY_W,"back":KEY_S,"left":KEY_A,"right":KEY_D,"sprint":KEY_SHIFT,"jump":KEY_SPACE,"crouch":KEY_C,"interact":KEY_E,"journal":KEY_J,"pause":KEY_ESCAPE,"equip":KEY_Q,"dodge":KEY_ALT,"shoulder":KEY_V,"performance":KEY_F3}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action,event)
	for action in ["attack","block"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT if action=="attack" else MOUSE_BUTTON_RIGHT
		InputMap.action_add_event(action,event)

func spawn_point() -> Vector3:
	return world.ground(world.path_x(40),40,0.3)

func create_npc(npc_name: String,role: String,x: float,z: float,key: String,walk: bool = false) -> void:
	var visual := Visual.new()
	visual.position = world.ground(x,z)
	visual.rotation.y = PI if z>0 else 0
	add_child(visual)
	visual.equipped = false
	A.label(visual,npc_name.to_upper()+"\n"+role,Vector3(0,2.5,0))
	npcs.append({"node":visual,"name":npc_name,"role":role,"key":key,"origin":visual.position,"walk":walk})

func start_game(continue_saved: bool) -> void:
	if not continue_saved:
		mission.reset()
	elif not mission.load_progress():
		interface.notify("The saved checkpoint could not be read. Starting a new journey.")
		mission.reset()
	playing = true
	player.health = 100
	player.set_mounted(false)
	player.velocity = Vector3.ZERO
	var checkpoint: Vector2 = mission.checkpoint()
	player.position = world.ground(checkpoint.x,checkpoint.y,0.3)
	parked_horse.position = world.ground(10,21,0.1)
	parked_horse.show()
	reset_patrol()
	interface.enter_game()
	if not continue_saved:
		interface.notify("THE FIRST OATH  ·  Your journey begins in Ambe village")
	if not ambient.playing:
		ambient.play()

func reset_patrol() -> void:
	enemy.position = world.ground(world.path_x(-55),-55,0.2)
	enemy.health = 100
	enemy.alert = 0
	enemy.state = "PATROL"
	enemy.visual.rotation.z = 0
	enemy.visual.position.y = 0
	enemy.collision_layer = 4

func recover_player() -> void:
	var was_mounted: bool = player.mounted
	player.set_mounted(false)
	player.health = 100
	player.velocity = Vector3.ZERO
	var checkpoint: Vector2 = mission.checkpoint()
	player.position = world.ground(checkpoint.x,checkpoint.y,0.4)
	if was_mounted:
		parked_horse.position = world.ground(checkpoint.x+1.8,checkpoint.y,0.1)
		parked_horse.show()
	reset_patrol()
	interface.notify("Returned to your last safe checkpoint")

func complete_event(event: String) -> void:
	if mission.advance(event):
		if mission.stage==8:
			mission.supplies = false
		if not save_checkpoint():
			return
		if mission.stage==8:
			interface.notify("THE FIRST OATH COMPLETE  ·  The western water route awaits")
		else:
			interface.notify("CHECKPOINT SAVED  ·  "+mission.current().title)

func save_checkpoint() -> bool:
	if not mission.save_progress():
		interface.notify(mission.last_save_error)
		return false
	return true

func near_objective(radius: float = 4.5) -> bool:
	var target: Dictionary = mission.current()
	return player.position.distance_to(world.ground(target.x,target.z))<radius

func interaction_prompt() -> String:
	if near_objective():
		match mission.stage:
			0: return "[ E ]  Speak with Keshav"
			1: return "[ E ]  Collect grain & bandages"
			3: return "[ E ]  Take in the valley"
			4: return "[ E ]  Dismount Badal" if player.mounted else "[ E ]  Observe the patrol"
			6: return "[ E ]  Speak with Jiva"
			7: return "[ E ]  Deliver the supplies"
	if player.mounted:
		return "[ E ]  Dismount Badal"
	if player.position.distance_to(parked_horse.position)<3.7:
		return "[ E ]  Mount Badal"
	for npc in npcs:
		if player.position.distance_to(npc.node.position)<3:
			return "[ E ]  Speak with "+npc.name
	return ""

func interact() -> void:
	if near_objective():
		match mission.stage:
			0:
				interface.dialogue(dialogue.elder_name,dialogue.elder,func(): complete_event("elder"))
				return
			1:
				complete_event("supplies")
				return
			3:
				if player.mounted:
					interface.dialogue(dialogue.lookout_name,dialogue.lookout,func(): complete_event("lookout"))
				else:
					interface.notify("Bring Badal to the lookout to complete the ride.")
				return
			4:
				if not player.mounted:
					interface.dialogue(dialogue.observe_name,dialogue.observe,func(): complete_event("observe"))
					return
			6:
				interface.dialogue(dialogue.guard_name,dialogue.guard,func(): complete_event("gate"))
				return
			7:
				interface.dialogue(dialogue.oath_name,dialogue.oath,func(): complete_event("oath"))
				return
	if player.mounted:
		dismount()
		return
	if player.position.distance_to(parked_horse.position)<3.7:
		player.position = parked_horse.position+Vector3.UP*0.15
		player.facing = parked_horse.rotation.y
		parked_horse.hide()
		player.set_mounted(true)
		complete_event("mount")
		return
	for npc in npcs:
		if player.position.distance_to(npc.node.position)<3:
			interface.dialogue(npc.name+" · "+npc.role,dialogue.get(npc.key,"The mountain road awaits."))
			return
	if not player.try_climb():
		interface.notify("Move closer to a person, supplies, Badal, or a low ledge.")

func dismount() -> void:
	# Test the complete standing capsule so dismounting cannot put a rider inside a wall.
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.85
	for direction in [Vector3.RIGHT,Vector3.LEFT,Vector3.BACK,Vector3.FORWARD]:
		var candidate: Vector3 = player.position+direction*1.8
		candidate.y = world.height_at(candidate.x,candidate.z)+0.15
		if absf(candidate.y-player.position.y)>1.5:
			continue
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform = Transform3D(Basis(),candidate+Vector3.UP*0.94)
		query.collision_mask = 1
		if not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():
			continue
		parked_horse.position = player.position
		parked_horse.rotation.y = player.facing
		parked_horse.show()
		player.set_mounted(false)
		player.position = candidate
		player.velocity = Vector3.ZERO
		return
	interface.notify("Find a little more space to dismount.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("performance"):
		show_performance = not show_performance
	if not playing:
		return
	if event.is_action_pressed("pause"):
		if interface.dialogue_open:
			interface.finish_dialogue()
		else:
			interface.pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		if interface.dialogue_open:
			interface.finish_dialogue()
		elif not interface.modal:
			interact()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("journal"):
		if interface.overlay:
			interface.close_overlay()
		else:
			interface.show_journal()

func _process(delta: float) -> void:
	elapsed += delta
	if not is_instance_valid(interface):
		return
	var target: Dictionary = mission.current()
	marker.position = world.ground(target.x,target.z,3.4+sin(elapsed*2)*0.15)
	marker.rotation.y += delta
	marker.visible = playing and mission.stage<8
	supplies.visible = mission.stage<2
	for i in npcs.size():
		var npc: Dictionary = npcs[i]
		var visual: Node3D = npc.node
		if npc.walk and playing and not interface.modal:
			var x: float = npc.origin.x+sin(elapsed*0.2+i)*3
			visual.position = world.ground(x,npc.origin.z)
			visual.rotation.y = -PI/2 if cos(elapsed*0.2+i)>0 else PI/2
		visual.animate(delta,0.6 if npc.walk and playing and not interface.modal else 0.0,true,false,false,false)
	if playing and not interface.modal and mission.stage==5:
		if player.position.z<-68 and player.crouched and not player.mounted and enemy.alert<0.15:
			complete_event("pass_patrol")

func apply_quality(value: int,persist: bool = true) -> void:
	quality = clampi(value,0,3)
	get_viewport().scaling_3d_scale = [0.65,0.80,0.90,1.0][quality]
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED if quality==0 else (Viewport.MSAA_4X if quality==3 else Viewport.MSAA_2X)
	world.sun.shadow_enabled = quality>0
	world.sun.directional_shadow_max_distance = [45,75,130,180][quality]
	var grass: MultiMeshInstance3D = world.vegetation[0]
	grass.multimesh.visible_instance_count = [2400,6000,10500,14000][quality]
	grass.visibility_range_end = [45,65,85,110][quality]
	if persist:
		save_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("graphics","quality",quality)
	config.set_value("camera","sensitivity",player.sensitivity)
	config.set_value("camera","shoulder",player.shoulder)
	config.set_value("audio","muted",AudioServer.is_bus_mute(0))
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg")!=OK:
		return
	var q: Variant = config.get_value("graphics","quality",2)
	if q is int:
		quality = clampi(q,0,3)
	var sensitivity: Variant = config.get_value("camera","sensitivity",0.0028)
	if (sensitivity is float or sensitivity is int) and is_finite(float(sensitivity)):
		player.sensitivity = clampf(float(sensitivity),0.0008,0.006)
	player.shoulder = config.get_value("camera","shoulder",false)==true
	AudioServer.set_bus_mute(0,config.get_value("audio","muted",false)==true)
