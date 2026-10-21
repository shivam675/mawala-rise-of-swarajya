extends Control

var game: Node

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not game.playing:
		return
	var center := Vector2(size.x/2,42)
	var cream := Color("e8d8ba")
	var muted := Color(0.9,0.8,0.65,0.24)
	draw_line(center+Vector2(-140,8),center+Vector2(140,8),muted,1)
	for i in range(-8,9):
		var x: float = i*17
		draw_line(center+Vector2(x,4),center+Vector2(x,10 if i%2 else 14),muted,1)
	var target: Dictionary = game.mission.current()
	var direction: Vector3 = game.world.ground(target.x,target.z)-game.player.position
	var bearing: float = wrapf(atan2(-direction.x,-direction.z)-game.player.yaw,-PI,PI)
	var marker_x: float = clampf(bearing*100,-137,137)
	var p := center+Vector2(marker_x,2)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-5),p+Vector2(4,0),p+Vector2(0,5),p+Vector2(-4,0)]),Color("e9a65b"))
	draw_string(ThemeDB.fallback_font,center+Vector2(-4,-10),"N",HORIZONTAL_ALIGNMENT_CENTER,-1,13,cream)
	# Small ridge map uses the same route as the playable terrain.
	var map_center := Vector2(size.x-92,size.y-128)
	draw_circle(map_center,56,Color(0.075,0.085,0.075,0.65))
	draw_arc(map_center,56,0,TAU,80,Color(0.8,0.7,0.5,0.4),1,true)
	for ring in 5:
		var points := PackedVector2Array()
		for i in 49:
			var a: float = i*TAU/48
			var r: float = 11+ring*9+sin(a*3+ring)*4
			points.append(map_center+Vector2(cos(a)*r,sin(a)*r*0.8))
		draw_polyline(points,Color(0.75,0.7,0.5,0.12),1,true)
	var path := PackedVector2Array()
	for i in 30:
		var z: float = 65-i*6
		path.append(map_center+Vector2(game.world.path_x(z)*0.35,z*0.45+8))
	draw_polyline(path,Color("a78a60"),1.3,true)
	var player := map_center+Vector2(game.player.position.x*0.35,game.player.position.z*0.45+8)
	draw_circle(player,3.5,cream)
	var goal := map_center+Vector2(float(target.x)*0.35,float(target.z)*0.45+8)
	draw_arc(goal,4.5,0,TAU,16,Color("e6a159"),1.5,true)
