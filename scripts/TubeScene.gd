extends VBoxContainer

signal tube_clicked(tube_number, is_neck)
var tube_pressed: bool = false

const PORTION_SCENE := preload("res://scenes/PortionScene.tscn")
const BORDER: float = 0.03 # in %

#var tube_position : Vector2
var tube_number: int = 0 # 1..MAX_TUBE_NUMBER

var tube_content: Array = []
var drains: int = 0 # local copy of corresponding Tube.drains

var portion_size: Vector2

onready var tube_container: VBoxContainer = $Tube
onready var up: TextureRect = $Up
onready var down: TextureRect = $Down


func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("tube_clicked", Globals.game_scene, "_on_tube_clicked")


func init(tube_num: int, tube: Array) -> void:
	if check(tube):
		#var a = tube_container.get_child(0)
		#tube_container.remove_child(a)
		#a.queue_free()
		tube_number = tube_num
		tube_content.resize(Globals.get_level_biggest_tube())
		#var size_diff: int = Globals.MAX_TUBE_VOLUME - tube.size()
		for i in tube_content.size():
			var portion := PORTION_SCENE.instance()
			#var portion_pos_y : float = tube_position.y + TUBE_SIZE.y * BORDER + portion_size.y * i# + size_diff)
			#portion.set_coords(Vector2(tube_position.x + TUBE_SIZE.x * BORDER, \
			#		portion_pos_y), portion_size)
			tube_content[i] = portion
			tube_container.add_child(tube_content[i])
			if i < tube.size():
				tube_content[i].set_color(0)
			else:
				tube_content[i].set_color(-1)
	

# check before every update
func check(tube: Array) -> bool:
	if tube.empty():
		print_debug("Tube is empty")
		return false
	if tube.size() > Globals.MAX_TUBE_VOLUME:
		print_debug("Tube is too big: ", tube.size())
		return false
	for each in tube:
		if each < 0 || each > Globals.MAX_COLORS:
			print_debug("Wrong color: ", each)
			return false
	return true
	

func update_tube(tube: Array) -> void:
	if check(tube):
		#var curr_portion: int = tube.size() - 1
		for i in range(tube.size() - 1, -1, -1):
			tube_content[i].set_color(tube[i])
			#curr_portion -= 1


func reset_pointers() -> void:
	tube_pressed = false
	_on_TubeScene_mouse_exited()
	

func set_pointers(drains_val: int) -> void:
#Tube enum DRAINS {NECK, BOTTOM, BOTH}
	if drains_val in Tube.DRAINS.values():
		drains = drains_val
		if drains == Tube.DRAINS.NECK:
			down.set_modulate(Color.transparent)
		elif drains == Tube.DRAINS.BOTTOM:
			up.set_modulate(Color.transparent)
		else:
			pass


func _on_TubeScene_mouse_entered():
	if tube_pressed:
		return
	if drains == Tube.DRAINS.NECK:
		up.set_modulate(Color.white)
	elif drains == Tube.DRAINS.BOTTOM:
		down.set_modulate(Color.white)
	else:
		if get_local_mouse_position().y < get_size().y / 2:
			up.set_modulate(Color.white)
		else:
			down.set_modulate(Color.white)


func _on_TubeScene_mouse_exited():
	if tube_pressed:
		return
	if drains == Tube.DRAINS.NECK || drains == Tube.DRAINS.BOTH:
		up.set_modulate(Color8(255, 255, 255, 64))
	if drains == Tube.DRAINS.BOTTOM || drains == Tube.DRAINS.BOTH:
		down.set_modulate(Color8(255, 255, 255, 64))


func _on_TubeScene_gui_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		tube_pressed = true
		if drains == Tube.DRAINS.NECK:
			emit_signal("tube_clicked", tube_number, true)
			up.set_modulate(Color.greenyellow)
		elif drains == Tube.DRAINS.BOTTOM:
			emit_signal("tube_clicked", tube_number, false)
			down.set_modulate(Color.greenyellow)
		elif drains == Tube.DRAINS.BOTH:
			if event.position.y < get_size().y / 2:
				emit_signal("tube_clicked", tube_number, true)
				up.set_modulate(Color.greenyellow)
			else:
				emit_signal("tube_clicked", tube_number, false)
				down.set_modulate(Color.greenyellow)
		else:
			pass

