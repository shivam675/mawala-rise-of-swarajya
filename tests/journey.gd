extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("run")

func reach(x: float,z: float) -> void:
	game.player.position = game.world.ground(x,z,0.25)
	game.player.velocity = Vector3.ZERO
	for i in 6:
		await physics_frame

func run() -> void:
	game = load("res://core/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game(false)
	await reach(10,34)
	game.interact()
	assert(game.interface.dialogue_open and game.mission.stage==0,"E opens elder dialogue without skipping it")
	game.interface.finish_dialogue()
	assert(game.mission.stage==1,"Finishing elder dialogue advances quest")
	await reach(-9,43)
	game.interact()
	assert(game.mission.stage==2 and game.mission.supplies,"Collect actual supply object")
	await reach(10,21)
	game.interact()
	assert(game.player.mounted and game.mission.stage==3,"Interact mounts actual horse")
	game.player.position = Vector3(-115,-30,-55)
	await physics_frame
	await physics_frame
	assert(not game.player.mounted and game.player.position.distance_to(game.parked_horse.position)<3.7,"Fall recovery must keep the horse reachable during the riding objective")
	game.interact()
	assert(game.player.mounted,"Rider can remount after falling")
	Input.action_press("forward")
	Input.action_press("sprint")
	for i in 600:
		var target: Vector3 = game.world.ground(game.world.path_x(game.player.position.z-4),game.player.position.z-4)
		var offset: Vector3 = target-game.player.position
		game.player.yaw = atan2(-offset.x,-offset.z)
		await physics_frame
		if game.player.position.z<-26:
			break
	Input.action_release("forward")
	Input.action_release("sprint")
	assert(game.player.position.z<-24,"Horse must physically travel the ridge")
	assert(game.player.is_on_floor(),"Rider follows terrain")
	game.interact()
	assert(game.interface.dialogue_open,"Lookout interaction must trigger")
	game.interface.finish_dialogue()
	assert(game.mission.stage==4,"Lookout advances quest")
	game.dismount()
	assert(not game.player.mounted,"Actual dismount finds clear ground")
	assert(game.player.position.distance_to(game.parked_horse.position)>1,"Dismount leaves horse alongside rider")
	await reach(-5.7,-27)
	game.interact()
	game.interface.finish_dialogue()
	assert(game.mission.stage==5,"Observe patrol opens stealth stage")
	# Approach the crossing with the guard's back turned; real detection must still work.
	await reach(game.world.path_x(-55),-63)
	game.player.crouched = true
	game.enemy.facing = PI
	assert(not game.enemy.can_see_player(),"Crouching outside short detection range conceals player")
	game.player.crouched = false
	game.enemy.facing = 0
	assert(game.enemy.can_see_player(),"Standing inside forward cone is visible")
	game.enemy.facing = PI
	assert(not game.enemy.can_see_player(),"Guard does not see behind itself")
	game.player.crouched = true
	game.enemy.alert = 0
	await reach(-7.4,-71)
	await process_frame
	assert(game.mission.stage==6,"Reaching northern ridge quietly completes stealth")
	await reach(0,-79)
	game.interact()
	game.interface.finish_dialogue()
	assert(game.mission.stage==7,"Gate sentry permits delivery")
	# Walk through the real arch rather than teleporting through a solid fort wall.
	game.player.crouched = false
	game.player.yaw = 0
	Input.action_press("forward")
	for i in 240:
		await physics_frame
		if game.player.position.z<-91:
			break
	Input.action_release("forward")
	assert(game.player.position.z<-89,"Fort entrance must be physically traversable")
	await reach(-5,-99)
	game.interact()
	game.interface.finish_dialogue()
	assert(game.mission.stage==8 and not game.mission.supplies,"Delivery completes mission and consumes supplies")
	assert(game.mission.load_progress() and game.mission.stage==8,"Completed quest round-trips through disk save")
	game.player.health = 12
	game.player.position.y = -40
	await physics_frame
	await physics_frame
	assert(game.player.health==100 and game.player.position.z<-80,"Falling returns to safe checkpoint")
	game.enemy.take_damage(100)
	assert(game.enemy.health==0 and game.enemy.state=="DEFEATED","Enemy can be defeated")
	game.player.dodge_time = 0.38
	game.player.dodge_direction = Vector3.RIGHT
	var paused_position: Vector3 = game.player.position
	game.interface.pause()
	for i in 15:
		await physics_frame
	assert(game.player.position.distance_to(paused_position)<0.001,"Pausing must freeze an active dodge")
	game.interface.close_overlay()
	var original_stage: int = game.mission.stage
	game.mission.reset()
	DirAccess.rename_absolute(game.mission.SAVE_PATH,game.mission.SAVE_PATH+".backup")
	DirAccess.make_dir_absolute(game.mission.SAVE_PATH+".tmp")
	game.complete_event("elder")
	assert(not game.mission.last_save_error.is_empty(),"Write failure must be reported")
	assert(game.interface.toast.text==game.mission.last_save_error,"Write failure must never report CHECKPOINT SAVED")
	game.interface.return_to_title()
	assert(game.playing and game.interface.modal and not game.interface.menu.visible,"Failed save must keep the current journey open")
	game.interface.close_overlay()
	DirAccess.remove_absolute(game.mission.SAVE_PATH+".tmp")
	DirAccess.rename_absolute(game.mission.SAVE_PATH+".backup",game.mission.SAVE_PATH)
	game.mission.stage = original_stage
	print("PASS: dialogue, supply pickup, physical riding, lookout, safe dismount, detection cone, stealth checkpoint, traversable gate, delivery, disk save, rider recovery, enemy health, pause, save failures")
	game.ambient.stop()
	game.queue_free()
	await process_frame
	OS.delay_msec(80)
	await process_frame
	quit(0)
