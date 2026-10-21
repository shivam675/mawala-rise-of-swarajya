extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://core/main.tscn")
	assert(scene != null, "Playable main scene must load")
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	assert(game.world != null, "Terrain must exist")
	assert(game.player != null, "Animated player must exist")
	assert(game.mission != null, "Quest must exist")
	assert(game.player.visual.joints.size() == 4, "Player must have knee and elbow joints")
	assert(game.player.horse.knees.size() == 4, "Horse must have four knee joints")
	for i in 60:
		game.player.horse.animate(1.0/60.0,17.0)
	assert(game.player.horse.gait_speed > 16.0, "Horse must blend into gallop")
	assert(game.player.horse.position.y >= 0, "Horse bounce must not sink below its root")
	for i in 120:
		game.player.horse.animate(1.0/60.0,0.0)
	assert(absf(game.player.horse.legs[0].rotation.x) < 0.001, "Horse must settle after stopping")
	game.player.visual.animate(0.1,7.0,true,false,false,false)
	assert(game.player.visual.joints[2].rotation.x < 0, "Running must bend the elbow")
	game.player.visual.animate(1.0,0,true,false,true,false)
	assert(game.player.visual.joints[0].rotation.x > 1.0, "Rider must bend the knees")
	assert(game.interface.toast.global_position.x>=0, "Toast must remain inside viewport")
	assert(game.interface.stats.global_position.y>0, "Footer must remain inside viewport")
	game.interface.show_settings()
	await process_frame
	var panel = game.interface.overlay.get_child(1)
	assert(panel.global_position.x>=0 and panel.global_position.y>=0, "Settings must be centered inside viewport")
	game.interface.close_overlay()
	assert(game.world.height_at(0, -104) > game.world.height_at(0, 45), "Fort must stand above village")
	game.interface.dialogue(game.dialogue.oath_name,game.dialogue.oath)
	await process_frame
	await process_frame
	var dialogue_box = game.interface.overlay.get_child(1)
	assert(dialogue_box.global_position.y+dialogue_box.size.y <= game.interface.root.size.y, "Long story dialogue must fit the viewport")
	game.interface.close_overlay()
	game.start_game(false)
	for i in 90:
		await physics_frame
	assert(game.player.is_on_floor(), "Player must settle onto collision terrain")
	var start: Vector3 = game.player.position
	Input.action_press("forward")
	for i in 60:
		await physics_frame
	Input.action_release("forward")
	assert(game.player.position.distance_to(start) > 2.0, "W must actually move player")
	Input.action_press("jump")
	await physics_frame
	await physics_frame
	Input.action_release("jump")
	assert(game.player.velocity.y > 0, "Jump must lift player")
	game.player.position = game.spawn_point()
	game.player.velocity = Vector3.ZERO
	game.mission.reset()
	assert(not game.mission.advance("supplies"), "Quest rejects out-of-order actions")
	for event in ["elder", "supplies", "mount", "lookout", "observe", "pass_patrol", "gate", "oath"]:
		assert(game.mission.advance(event), "Quest accepts ordered action: " + event)
	assert(game.mission.stage == 8, "Quest must finish and issue next objective")
	assert(not game.mission.advance("oath"), "Completed quest cannot overflow")
	assert(not game.mission.restore({"version": 1, "stage": 99}), "Reject invalid save stage")
	assert(not game.mission.restore({"version": 1, "stage": 2.5}), "Reject fractional save stage")
	assert(not game.mission.restore({"version": 9, "stage": 1}), "Reject unknown save version")
	assert(game.mission.restore({"version": 1, "stage": 3}), "Restore valid progress")
	game.player.set_mounted(true)
	assert(game.player.mounted, "Mount toggles riding state")
	game.player.set_mounted(false)
	assert(not game.player.mounted, "Dismount restores walking state")
	game.player.take_damage(15)
	assert(game.player.health == 85, "Damage affects health")
	game.player.blocking = true
	game.player.take_damage(15)
	assert(game.player.health == 82, "Block reduces damage")
	print("PASS: terrain, movement, jump, quest ordering, save validation, riding, health, blocking")
	game.ambient.stop()
	game.queue_free()
	await process_frame
	OS.delay_msec(80)
	await process_frame
	quit(0)
