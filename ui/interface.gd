extends CanvasLayer

const Wayfinder = preload("res://ui/wayfinder.gd")
var game: Node
var root: Control
var hud: Control
var menu: Control
var menu_content: VBoxContainer
var overlay: Control
var modal: bool = true
var dialogue_open: bool = false
var dialogue_callback: Callable
var objective: Label
var objective_detail: Label
var prompt: Label
var health: ProgressBar
var stats: Label
var place: Label
var state_label: Label
var toast: Label
var toast_time: float = 0
var serif: Font
var menu_title: Label
var continue_button: Button

func _ready() -> void:
	serif = load("res://art/fonts/CormorantGaramond.ttf")
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	var body_font: FontFile = load("res://art/fonts/DejaVuSans.ttf")
	body_font.fallbacks = [load("res://art/fonts/NotoSansDevanagari-Regular.ttf")]
	theme.default_font = body_font
	theme.default_font_size = 17
	theme.set_color("font_color","Label",Color("efe3ca"))
	theme.set_color("font_color","Button",Color("ead9b9"))
	theme.set_color("font_hover_color","Button",Color("ffbe74"))
	for state in ["normal","hover","pressed","focus","disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12,0.12,0.10,0.9) if state=="normal" else Color(0.25,0.20,0.14,0.95)
		style.border_color = Color("aa8754") if state in ["hover","focus"] else Color(0.7,0.6,0.4,0.3)
		style.set_border_width_all(1)
		style.content_margin_left = 23
		style.content_margin_right = 23
		style.content_margin_top = 13
		style.content_margin_bottom = 13
		theme.set_stylebox(state,"Button",style)
	root.theme = theme
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)
	var navigation := Wayfinder.new()
	navigation.game = game
	navigation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	navigation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(navigation)
	label(hud,"मावळा  /  MAVALA",Vector2(40,32),18)
	health = ProgressBar.new()
	health.position = Vector2(40,69)
	health.size = Vector2(150,4)
	health.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("c6a272")
	health.add_theme_stylebox_override("fill",fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.2,0.18,0.14,0.65)
	health.add_theme_stylebox_override("background",bg)
	hud.add_child(health)
	state_label = label(hud,"",Vector2(40,86),12)
	var objective_box := VBoxContainer.new()
	objective_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	objective_box.offset_left = -355
	objective_box.offset_right = -40
	objective_box.offset_top = 37
	objective_box.offset_bottom = 200
	objective_box.add_theme_constant_override("separation",9)
	hud.add_child(objective_box)
	var chapter := make_label("THE FIRST OATH",12)
	chapter.modulate = Color("e0a15b")
	objective_box.add_child(chapter)
	objective = make_label("",27,true)
	objective_box.add_child(objective)
	objective_detail = make_label("",15)
	objective_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_detail.custom_minimum_size.x = 310
	objective_box.add_child(objective_detail)
	place = label(hud,"THE MAVAL COUNTRY",Vector2(40,-133),15)
	place.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	place.offset_left = 40
	place.offset_top = -126
	place.offset_right = 480
	place.offset_bottom = -99
	var era := label(hud,"SAHYADRI  ·  CIRCA 1646",Vector2(40,-94),12)
	era.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	era.offset_left = 40
	era.offset_top = -92
	era.offset_right = 480
	era.offset_bottom = -70
	era.modulate = Color("c2b596")
	var controls := label(hud,"WASD  Move    MMB drag  Look    SHIFT  Sprint    SPACE  Jump    E  Interact    J  Journal    ESC  Pause",Vector2(40,-43),12)
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	controls.offset_left = 40
	controls.offset_top = -40
	controls.offset_right = 1100
	controls.offset_bottom = -15
	controls.modulate = Color("c2b596")
	prompt = label(hud,"",Vector2.ZERO,18)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.offset_left = -250
	prompt.offset_top = -137
	prompt.offset_right = 250
	prompt.offset_bottom = -92
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast = label(hud,"",Vector2.ZERO,16)
	toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast.offset_left = -320
	toast.offset_top = 90
	toast.offset_right = 320
	toast.offset_bottom = 120
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats = label(hud,"",Vector2.ZERO,11)
	stats.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	stats.offset_left = -255
	stats.offset_top = -62
	stats.offset_right = -40
	stats.offset_bottom = -40
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(menu)
	var fade := ColorRect.new()
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){float fade=1.0-smoothstep(0.18,0.79,UV.x); COLOR=vec4(0.035,0.045,0.042,fade*0.94); }"
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	fade.material = shader_material
	menu.add_child(fade)
	label(menu,"⚑    A SAHYADRI CHRONICLE",Vector2(76,56),13).modulate = Color("d6a063")
	menu_content = VBoxContainer.new()
	menu_content.position = Vector2(76,212)
	menu_content.size.x = 545
	menu_content.add_theme_constant_override("separation",12)
	menu.add_child(menu_content)
	menu_title = make_label("MAVALA",112,true)
	menu_content.add_child(menu_title)
	var subtitle := make_label("R I S E   O F   S W A R A J Y A",19)
	subtitle.modulate = Color("d6b683")
	menu_content.add_child(subtitle)
	var line := HSeparator.new()
	line.custom_minimum_size.y = 20
	menu_content.add_child(line)
	var description := make_label("A quiet village. A mountain road.\nThe first steps towards something greater.",18)
	description.add_theme_constant_override("line_spacing",8)
	menu_content.add_child(description)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 15
	menu_content.add_child(spacer)
	button(menu_content,"BEGIN YOUR JOURNEY     →",new_game)
	continue_button = button(menu_content,"CONTINUE",func(): game.start_game(true))
	continue_button.disabled = not game.mission.load_progress()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",12)
	menu_content.add_child(row)
	button(row,"SETTINGS",show_settings)
	button(row,"CREDITS & HISTORY",show_credits)
	var footer := label(menu,"MAHARASHTRA, CIRCA 1646\nA fictional journey inspired by the lands and people of Maval.",Vector2.ZERO,13)
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	footer.offset_left = 76
	footer.offset_top = -77
	footer.offset_right = 680
	footer.offset_bottom = -20
	footer.add_theme_constant_override("line_spacing",8)
	footer.modulate = Color("b5ab95")
	hud.hide()

func make_label(text: String,font_size: int,heading: bool = false) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",font_size)
	if heading:
		node.add_theme_font_override("font",serif)
	node.add_theme_color_override("font_shadow_color",Color(0,0,0,0.5))
	node.add_theme_constant_override("shadow_offset_x",1)
	node.add_theme_constant_override("shadow_offset_y",2)
	return node

func label(parent: Node,text: String,pos: Vector2,font_size: int) -> Label:
	var node := make_label(text,font_size)
	node.position = pos
	parent.add_child(node)
	return node

func button(parent: Node,text: String,action: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(action)
	parent.add_child(node)
	return node

func new_game() -> void:
	if FileAccess.file_exists(game.mission.SAVE_PATH):
		var content := panel("A new beginning")
		content.add_child(make_label("Starting again replaces your First Oath checkpoint.",17))
		button(content,"BEGIN AGAIN",func(): close_overlay(); game.start_game(false))
		button(content,"KEEP MY JOURNEY",close_overlay)
	else:
		game.start_game(false)

func enter_game() -> void:
	menu.hide()
	hud.show()
	modal = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if OS.has_feature("web") else Input.MOUSE_MODE_CAPTURED

func pause() -> void:
	if overlay:
		close_overlay()
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var content := panel("A moment on the mountain")
	button(content,"RESUME JOURNEY",close_overlay)
	button(content,"QUEST JOURNAL",show_journal)
	button(content,"SETTINGS",show_settings)
	button(content,"SAVE & RETURN TO TITLE",return_to_title)

func return_to_title() -> void:
	if not game.save_checkpoint():
		var content := panel("Unable to save progress")
		content.add_child(make_label(game.mission.last_save_error,17))
		button(content,"RESUME JOURNEY",close_overlay)
		return
	close_overlay()
	game.playing = false
	modal = true
	menu.show()
	hud.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	continue_button.disabled = false

func panel(title: String) -> VBoxContainer:
	if overlay:
		overlay.queue_free()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(overlay)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025,0.035,0.03,0.8)
	overlay.add_child(shade)
	var box := PanelContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.offset_left = -325
	box.offset_top = -290
	box.offset_right = 325
	box.offset_bottom = 290
	box.custom_minimum_size = Vector2(650,580)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("171c17")
	style.border_color = Color("786a49")
	style.set_border_width_all(1)
	style.content_margin_left = 35
	style.content_margin_right = 35
	style.content_margin_top = 27
	style.content_margin_bottom = 27
	box.add_theme_stylebox_override("panel",style)
	overlay.add_child(box)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",15)
	box.add_child(content)
	content.add_child(make_label(title,38,true))
	modal = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return content

func close_overlay() -> void:
	if overlay:
		overlay.queue_free()
		overlay = null
	dialogue_open = false
	modal = not game.playing
	if game.playing:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if OS.has_feature("web") else Input.MOUSE_MODE_CAPTURED

func dialogue(speaker: String,text: String,callback: Callable = Callable()) -> void:
	var content := panel(speaker)
	dialogue_open = true
	dialogue_callback = callback
	var words := make_label(text,21)
	words.custom_minimum_size = Vector2(565,210)
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.add_theme_constant_override("line_spacing",12)
	content.add_child(words)
	content.add_child(make_label("Fictional dialogue · English subtitles",12))
	button(content,"CONTINUE    [E]",finish_dialogue)

func finish_dialogue() -> void:
	var callback := dialogue_callback
	dialogue_callback = Callable()
	close_overlay()
	if callback.is_valid():
		callback.call()

func show_journal() -> void:
	var content := panel("The First Oath")
	for i in game.mission.stages.size():
		var item: Dictionary = game.mission.stages[i]
		var text: String = ("✓  " if i<game.mission.stage else ("→  " if i==game.mission.stage else "·  "))+item.title
		var entry := make_label(text,17)
		entry.modulate = Color("e7b473") if i==game.mission.stage else Color("a9ad99")
		content.add_child(entry)
	content.add_child(make_label("SATCHEL    "+("Grain & bandages" if game.mission.supplies else "Empty"),14))
	button(content,"RETURN",close_overlay)

func show_settings() -> void:
	var content := panel("Make yourself at home")
	content.add_child(make_label("GRAPHICS",13))
	var quality := OptionButton.new()
	for item in ["LOW — lighter terrain","MEDIUM — balanced","HIGH — richer shadows","ULTRA — full resolution"]:
		quality.add_item(item)
	quality.select(game.quality)
	quality.item_selected.connect(game.apply_quality)
	content.add_child(quality)
	content.add_child(make_label("CAMERA SENSITIVITY",13))
	var sensitivity_slider := HSlider.new()
	sensitivity_slider.min_value = 0.0008
	sensitivity_slider.max_value = 0.006
	sensitivity_slider.step = 0.0001
	sensitivity_slider.value = game.player.sensitivity
	sensitivity_slider.value_changed.connect(func(value): game.player.sensitivity = value; game.save_settings())
	content.add_child(sensitivity_slider)
	var shoulder_button := CheckButton.new()
	shoulder_button.text = "Shoulder camera"
	shoulder_button.button_pressed = game.player.shoulder
	shoulder_button.toggled.connect(func(value): game.player.shoulder = value; game.save_settings())
	content.add_child(shoulder_button)
	var sound := CheckButton.new()
	sound.text = "Environmental sound"
	sound.button_pressed = not AudioServer.is_bus_mute(0)
	sound.toggled.connect(func(value): AudioServer.set_bus_mute(0,not value); game.save_settings())
	content.add_child(sound)
	content.add_child(make_label("C crouch   Q equip   LMB sword   RMB block\nALT dodge   V shoulder   Wheel zoom\nE mount / dismount / climb   F3 performance",14))
	button(content,"DONE",close_overlay)

func show_credits() -> void:
	var content := panel("A land worth remembering")
	var words := make_label("Original procedural characters, horse, architecture and vegetation.\n\nCC0 textures: Poly Haven — Sparse Grass; Rock Face 03.\nFont: Cormorant Garamond, SIL Open Font License.\nEngine: Godot, MIT license.\n\nInspired by Torna and the Maval region around 1646. The village, fort layout, people, dialogue and First Oath mission are fictional. This is not an exact reconstruction.\n\nSee ASSET_CREDITS.md and HISTORY_REFERENCES.md for source links and license details.",16)
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.custom_minimum_size.x = 565
	content.add_child(words)
	button(content,"RETURN",close_overlay)

func notify(text: String) -> void:
	toast.text = text
	toast_time = 5

func _process(delta: float) -> void:
	if not game.playing:
		return
	var current: Dictionary = game.mission.current()
	objective.text = current.title
	objective_detail.text = current.detail
	health.value = game.player.health
	state_label.text = "RIDING BADAL" if game.player.mounted else ("CROUCHED · QUIET" if game.player.crouched else "ON FOOT")
	if game.enemy.alert>0.1 and game.enemy.health>0:
		state_label.text = "DETECTED · BREAK LINE OF SIGHT" if game.enemy.state=="CHASE" else "PATROL IS SUSPICIOUS"
		state_label.modulate = Color("efa273")
	else:
		state_label.modulate = Color("c2b596")
	place.text = "THE FORT OF TORNA" if game.player.position.z < -80 else ("THE MOUNTAIN PASS" if game.player.position.z<15 else "THE VILLAGE OF AMBE")
	prompt.text = "" if modal else game.interaction_prompt()
	toast_time = maxf(0,toast_time-delta)
	toast.modulate.a = minf(toast_time,1)
	if game.show_performance:
		stats.text = "%d FPS  ·  %d MB  ·  %d draws" % [Engine.get_frames_per_second(),Performance.get_monitor(Performance.MEMORY_STATIC)/1048576,Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)]
	else:
		stats.text = "J  JOURNAL    ·    ESC  PAUSE"
