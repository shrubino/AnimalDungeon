extends Node2D

@export_category("Basics")
@export var width = 100
@export var height = 100
@export var roomcount = 50
@export var roomsize = 9
@export var buildingsize = 4
var regionsize = Vector2i(round((width*2)/(roomcount/buildingsize)), round((height*2)/(roomcount/buildingsize)))


@onready var tilemap = $TileMap
@onready var tileset = tilemap.tile_set
@onready var playerdog = $TileMap/PlayerDog
@onready var Keycounter = $TileMap/PlayerDog/positionlabel
@onready var item_scene = load("res://item.tscn")
@onready var itemnumber = 5
@onready var goblin_scene = load("res://goblin_1.tscn")
@onready var numberofgoblins = 50
@onready var goblin_positions = []
signal player_moved


@export_category("Organicness")
@export var o_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
@export var o_gain = 0.2
@export var o_octaves = 3
@export var o_lacunarity = 2
@export var o_frequency = .1

@export_category("Size")
@export var s_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
@export var s_gain = 0.1
@export var s_octaves = 3
@export var s_lacunarity = 2
@export var s_frequency = .1

var walltiles = {Vector2i.UP : Vector2i(1,2), Vector2i.DOWN: Vector2i(1,0), Vector2i.LEFT: Vector2i(2,1), Vector2i.RIGHT: Vector2i(0,1)}

#and generators
var rng = RandomNumberGenerator.new()

func _ready():
	playerdog.position = tilemap.map_to_local(playerdog.gridPosition)
	playerdog.mainController = self  
	add_user_signal("TurnChanged")
	generate_map()

func generate_noise(type, gain, octaves, lacunarity, frequency):
	# generate randomly seeded simplex noise map
	var name = FastNoiseLite.new()
	name.noise_type = type
	name.seed = randi()
	name.frequency = frequency
	name.fractal_octaves = octaves
	name.fractal_lacunarity = lacunarity
	name.fractal_gain = gain
	var grid = {}
	for x in height:
		for y in width:
			var rand = name.get_noise_2d(x,y) + 1
			grid[Vector2i(x, y)] = rand
	return grid

func generate_map():
	map_addBackground()
	map_addBiomes()
	map_addbuildings()
	map_addEnemies()
	map_addItems()
	get_tree().get_nodes_in_group("Enemy")
	
func map_addbuildings():
	create_building(Vector2i(0,0))
	var regioncounter
	var newlocation = Vector2i(-width,-height)
	while roomcount > 0:
		create_building(newlocation)
		newlocation += regionsize

func create_building(location):
	var buildingtiles = []
	var roomamount = buildingsize + randi_range(-1,6)
	var block = Vector2i.ZERO
	tilemap.set_pattern(0, location, tileset.get_pattern(randi_range(0,17)))
	var hasduck = false
	for room in roomamount:
		var roomID = randi_range(0,17)
		var duckcount = Global.duckcounter
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		if block != Vector2i(0,0):
			directions.erase(block)
		var newdirection = directions[randi_range(0,len(directions)-1)]
		var newposition = (newdirection * roomsize) + location
		if buildingtiles.has(newposition):
			continue
		if Global.ducktiles < 4 and hasduck == false:
			roomID = 18
			hasduck = true
			Global.ducktiles += 1
		block = newdirection * -1
		buildingtiles.append(newposition)
		roomcount -= 1
		tilemap.set_pattern(0, newposition, tileset.get_pattern(roomID))
		
	
	
	
#DEPRECATED:
#	map_addPatterns()
#	map_addBorder()

#func map_addBorder():
#	for x in width:
#			tilemap.set_cell(0, Vector2i(x,0), 0, Vector2i(1,0))
#			tilemap.set_cell(0, Vector2i(x,height), 0, Vector2i(1,2))
#	for y in height:
#			tilemap.set_cell(0, Vector2i(0,y), 0, Vector2i(0,1))
#			tilemap.set_cell(0, Vector2i(width,y), 0, Vector2i(2,1))
#	tilemap.set_cell(0, Vector2i(0,0), 0, Vector2i(0,0))
#	tilemap.set_cell(0, Vector2i(width,0), 0, Vector2i(2,0))
#	tilemap.set_cell(0, Vector2i(0,height), 0, Vector2i(0,2))
#	tilemap.set_cell(0, Vector2i(width,height), 0, Vector2i(2,2))


#func map_addPatterns():
#	for x in width:
#		for y in height:
#			if rng.randf() > .99:
#				tilemap.set_pattern(0, Vector2i(x,y), tileset.get_pattern(randi_range(0,20)))
#
func map_addBiomes():
	var org = generate_noise(o_type, o_gain, o_octaves, o_lacunarity, o_frequency)
	var size = generate_noise(s_type, s_gain, s_octaves, s_lacunarity, s_frequency)
	for x in width:
		for y in height:
			var pos = Vector2i(x,y)
			if org[pos] > 0.6 and size[pos] < 0.4:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(13,15), randi_range(0,2)), 0)
				tilemap.set_cell(0, Vector2i(-x,y), 0, Vector2i(randi_range(13,15), randi_range(0,2)), 0)
				tilemap.set_cell(0, Vector2i(x,-y), 0, Vector2i(randi_range(13,15), randi_range(0,2)), 0)
				tilemap.set_cell(0, Vector2i(-x,-y), 0, Vector2i(randi_range(13,15), randi_range(0,2)), 0)
			if org[pos] > 0.95 and size[pos] > 0.95:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(13,15), randi_range(3,4)), 0)
				tilemap.set_cell(0, Vector2i(-x,y), 0, Vector2i(randi_range(13,15), randi_range(3,4)), 0)
				tilemap.set_cell(0, Vector2i(x,-y), 0, Vector2i(randi_range(13,15), randi_range(3,4)), 0)
				tilemap.set_cell(0, Vector2i(-x,-y), 0, Vector2i(randi_range(13,15), randi_range(3,4)), 0)
			if org[pos] < 0.6:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(0,7), randi_range(20,21)), 0)
				tilemap.set_cell(0, Vector2i(-x,y), 0, Vector2i(randi_range(0,7), randi_range(20,21)), 0)
				tilemap.set_cell(0, Vector2i(x,-y), 0, Vector2i(randi_range(0,7), randi_range(20,21)), 0)
				tilemap.set_cell(0, Vector2i(-x,-y), 0, Vector2i(randi_range(0,7), randi_range(20,21)), 0)


func map_addBackground():
	for x in width:
		for y in height:
					tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(1,1))
					tilemap.set_cell(0, Vector2i(-x,-y), 0, Vector2i(1,1))
					tilemap.set_cell(0, Vector2i(x,-y), 0, Vector2i(1,1))
					tilemap.set_cell(0, Vector2i(-x,y), 0, Vector2i(1,1))

func map_addEnemies():
	for x in range(numberofgoblins):
		var new_goblin = goblin_scene.instantiate()
		add_child(new_goblin)
		new_goblin.tilemap = tilemap
		new_goblin.player = playerdog
		new_goblin.position = tilemap.map_to_local(new_goblin.gridPosition)
		goblin_positions.append(new_goblin.gridPosition)
		playerdog.player_moved.connect(new_goblin._on_player_moved)

func map_addItems():
	var spawnercells = tilemap.get_used_cells_by_id(0, 0, Vector2i(3,18))
	var duckcells = tilemap.get_used_cells_by_id(0,0, Vector2i(14,14))
	for cell in duckcells:
		var item = item_scene.instantiate()
		item.item_position = cell
		item.position = tilemap.map_to_local(item.item_position)
		item.itemname = Item.itemtypes.duckling
		print(item.item_position)
		add_child(item)
		Global.duckcounter += 1
	for cell in spawnercells:
		var item = item_scene.instantiate()
		item.item_position = cell
		item.position = tilemap.map_to_local(item.item_position)
		item.itemname = Item.itemtypes.key
#		add_child(item)

func between(val, start, end):
	if start <= val and val < end:
		return true

func player_turn():
	playerdog.emit_signal("player_moved")

func update_position():
	playerdog.position = tilemap.map_to_local(playerdog.gridPosition)
	Keycounter.text = str(playerdog.gridPosition)
	
func test_cell(coords: Vector2i, entity):
	var testingcell = entity.gridPosition + coords 
	var data = tilemap.get_cell_tile_data(0, testingcell)
	var shift_jump
	if entity.name != "PlayerDog":
		if data:
			if data.get_custom_data_by_layer_id(0) == 1: 
				return
			entity.gridPosition = entity.gridPosition + coords
			return
	if Input.is_action_pressed("shift_jump"):
		shift_jump = playerdog.shift_move_multiplier
	else :
		shift_jump = 1
	if data:
		if data.get_custom_data_by_layer_id(0) == 1: 
			if entity.walljump:
				entity.gridPosition += (-2 * coords)
				update_position()
			else:
				entity.gridPosition += (-1 * coords)
		if data.get_custom_data_by_layer_id(1) == true: #DETERMINES WHETHER A WALL IS THERE
			if playerdog.inventory.has(Item.itemtypes.key) and playerdog.inventory[Item.itemtypes.key] > 0 and entity.name == "PlayerDog":
				tilemap.set_cell(0, testingcell, 0, Vector2i(1,1))
				playerdog.inventory[Item.itemtypes.key] -= 1
				playerdog.emit_signal("player_moved")
			else:
				pass
		else: 
			var targetposition = entity.gridPosition + (coords * shift_jump)
			if test_for_goblin(targetposition) == false:
				entity.gridPosition = targetposition
				update_position()
			if test_for_item(targetposition) == true:
				update_position()

func test_for_item(targetposition):
	var items = get_tree().get_nodes_in_group("Items")
	for item in items:
		if is_instance_valid(item) and targetposition == item.item_position:
			playerdog.itemget(item.itemname)
			item.queue_free()

func test_for_goblin(targetposition):
	var goblins = get_tree().get_nodes_in_group("Enemy")
	for goblin in goblins:
		if is_instance_valid(goblin) and targetposition == goblin.gridPosition:
			goblin.health -= 1
			if goblin.health <= 0:
				goblin.queue_free()
				goblin_positions.erase(goblin)
				
				return false
			else:
				return true
	return false
