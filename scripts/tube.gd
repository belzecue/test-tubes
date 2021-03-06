extends GDScript
class_name Tube

# number of portions can contain
var _volume: int = 0 setget set_volume, get_volume

enum DRAINS {NECK, BOTTOM, BOTH}
var drains: int = DRAINS.NECK

var _content: Array = [] setget set_content, get_content


func _init():
	randomize()


func set_volume(volume: int = 0) -> void:
	if volume < 0:
		print_debug("Invalid volume (%s), setting to random" % volume)
		volume = 0
	if volume > Globals.MAX_TUBE_VOLUME:
		print_debug("Invalid volume (%s), setting to max" % volume)
		volume = Globals.MAX_TUBE_VOLUME
	if volume == 0:
		_volume = randi() % Globals.MAX_TUBE_VOLUME + 1
	_volume = volume
	if !is_empty():
		print_debug("This tube is not empty, couldn't change it's size")
		return
	_content.resize(_volume)
	
	
func get_volume() -> int:
	return _volume
	
	
func is_empty() -> bool:
	#print_debug(get_content())
	if _content.empty() || _content.back() == null || _content.back() == 0:
		return true
	return false
	
	
func set_content(new_content: Array) -> bool:
	if new_content.empty():
		print_debug("New content is empty")
		return false
	if new_content.size() != get_volume():
		print_debug("Invalid content size, it's doesn't match tube's volume")
		return false
	for each in new_content:
		if each < 0 || each > Globals.MAX_COLORS:
			print_debug("Invalid color value: ", each)
			return false
		
	_content.resize(new_content.size())
	for i in new_content.size():
		_content[i] = int(new_content[i])
	return true
	
	
# CAREFUL! returns the reference to the _content array
func get_content() -> Array:
	if _content.empty():
		_content.resize(get_volume())
		for i in _content.size():
			_content[i] = 0
	return _content
	
	
# portion = [1, 1, 1]
func add_a_portion(por: Array) -> Array:
	if drains == DRAINS.BOTTOM:
		print_debug("Can't add a portion cause tube's neck is sealed")
		Globals.send_message("Can't add a portion cause tube's neck is sealed")
		return por
	if por.size() == 0:
		print_debug("Empty portion")
		Globals.send_message("This portion is empty")
		return por
	if por.size() > Globals.MAX_TUBE_VOLUME:
		print_debug("Portion size is bigger than tube's size: ", por.size())
		return por
	if get_top_color() != 0 && get_top_color() != por[0]:
		print_debug("Source portion color doesn't match target's top color")
		Globals.send_message("Portion color doesn't match tube's top color")
		return por
	if por.size() > get_empty_volume():
		print_debug("There is not enough empty volume to add such size")
		return divide_a_portion(por)
		
	var empty_space: int = 0
	for i in get_volume():
		if _content[i] == 0:
			empty_space += 1
		else:
			break
	var start_fill_index: int = empty_space - por.size()
	for i in range(start_fill_index, start_fill_index + por.size()):
		_content[i] = por[0]
	return []


# add what's fit and returns what's not 
func divide_a_portion(por: Array) -> Array:
	if por.empty():
		print_debug("Empty portion, can't divide")
		return []
	var fitted_part: Array = por.duplicate()
	fitted_part.resize(get_empty_volume())
	var fitted_size: int = fitted_part.size()
	fitted_part = add_a_portion(fitted_part)
	if !fitted_part.empty():
		print_debug("Error while adding smaller portion, returning full portion")
		return por
	por.resize(por.size() - fitted_size)
	return por
	

# only from the neck
func drain_a_portion() -> Array:
	var por: Array = []
	if drains == DRAINS.BOTTOM:
		print_debug("Can't drain a portion from tube's neck cause it is sealed")
		return por
	if is_empty():
		return por
	#var por_color: int = get_top_color()
	var before: Array = get_content()
	for each in before:
		if each == 0:
			continue
		if each != 0 && por.empty():
			por.append(each)
		elif each == por[0]:
			por.append(each)
		else:
			break
	for i in before.size():
		if before[i] == 0:
			continue
		if before[i] == por[0]:
			before[i] = 0
		else:
			break
	if !set_content(before):
		print_debug("Error while draining")
		return []
	return por
	

func get_empty_volume() -> int:
	if is_empty():
		return get_volume()
	var empty_space: int = 0
	for each in get_content():
		if each == 0:
			empty_space += 1
		else:
			return empty_space
	# shouldn't be there
	return -1


# for draining through a faucet in the bottom
func drain_a_bottom_portion() -> Array:
	var por: Array = []
	if drains == DRAINS.NECK:
		print_debug("Can't drain a portion from tube's bottom cause it has no bottom faucet")
		return por
	if is_empty():
		return por
	var before: Array = get_content()
	for i in range(before.size() - 1, -1, -1):
		if before[i] == 0:
			#print_debug("It can't be true!")
			continue
		if before[i] != 0 && por.empty():
			por.append(before[i])
		elif before[i] == por[0]:
			por.append(before[i])
		else:
			break
	var after: Array = []
	after.resize(before.size())
	for i in range(after.size() - 1, -1, -1):
		if i - por.size() >= 0:
			after[i] = before[i - por.size()]
			continue
		else:
			after[i] = 0
	if !set_content(after):
		print_debug("Error while draining from bottom")
		return []
	return por
	

func get_top_color() -> int:
	if is_empty():
		return 0
	for each in get_content():
		if each == 0:
			continue
		return each
	return 0


# if adding was refused or partially returned
func restore_portion(por: Array) -> void:
	if por.empty():
		return
	if por.size() > get_empty_volume():
		print_debug("Portion size is invalid", por.size())
		return
		
	var empty_space: int = 0
	for i in get_volume():
		if _content[i] == 0:
			empty_space += 1
		else:
			break

	var start_fill_index: int = empty_space - por.size()
	for i in range(start_fill_index, start_fill_index + por.size()):
		_content[i] = por[0]


func restore_bottom_portion(por: Array) -> void:
	if por.empty():
		return
	if por.size() > get_empty_volume():
		print_debug("Portion size is invalid", por.size())
		return
		
	var before: Array = get_content()
	var after: Array = []
	after.resize(before.size())
	
	var j: int = por.size() - 1
	for i in range(after.size() - 1, -1, -1):
		if j >= 0:
			after[i] = por[j]
			j -= 1
		else:
			after[i] = before[i + por.size()]
			
	if !set_content(after):
		print_debug("Error while draining from bottom")



