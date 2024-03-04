extends Node2D

@export_category("Basics")
@export var width = 100
@export var height = 100

@onready var tilemap = $TileMap
@onready var tileset = tilemap.tile_set
@onready var playerdog = $TileMap/PlayerDog
@onready var positionlabel = $TileMap/PlayerDog/positionlabel
@onready var item_scene = load("res://item.tscn")
@onready var itemnumber = 5
@onready var goblin_scene = load("res://goblin_1.tscn")
@onready var numberofgoblins = 15
@onready var goblin_positions = []
signal player_moved


@export_category("Organicness")
@export var o_type = FastNoiseLite.TYPE_VALUE
@export var o_gain = 0.1
@export var o_octaves = 5
@export var o_lacunarity = 2
@export var o_frequency = .7

@export_category("Size")
@export var s_type = FastNoiseLite.TYPE_VALUE
@export var s_gain = 0.1
@export var s_octaves = 5
@export var s_lacunarity = 2
@export var s_frequency = .4

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
	map_addPatterns()
	map_addBorder()
	map_addEnemies()
	map_addItems()
	get_tree().get_nodes_in_group("Enemy")
	


func map_addBackground():
	for x in width:
		for y in height:
					tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(1,1))

func map_addBorder():
	for x in width:
			tilemap.set_cell(0, Vector2i(x,0), 0, Vector2i(1,0))
			tilemap.set_cell(0, Vector2i(x,height), 0, Vector2i(1,2))
	for y in height:
			tilemap.set_cell(0, Vector2i(0,y), 0, Vector2i(0,1))
			tilemap.set_cell(0, Vector2i(width,y), 0, Vector2i(2,1))
	tilemap.set_cell(0, Vector2i(0,0), 0, Vector2i(0,0))
	tilemap.set_cell(0, Vector2i(width,0), 0, Vector2i(2,0))
	tilemap.set_cell(0, Vector2i(0,height), 0, Vector2i(0,2))
	tilemap.set_cell(0, Vector2i(width,height), 0, Vector2i(2,2))

func map_addEnemies():
	for x in range(numberofgoblins):
		var new_goblin = goblin_scene.instantiate()
		add_child(new_goblin)
		new_goblin.tilemap = tilemap
		new_goblin.player = playerdog
		new_goblin.position = tilemap.map_to_local(new_goblin.enemy_position)
		goblin_positions.append(new_goblin.enemy_position)
		playerdog.player_moved.connect(new_goblin._on_player_moved)

func map_addPatterns():
	for x in width:
		for y in height:
			if rng.randf() > .99:
				tilemap.set_pattern(0, Vector2i(x,y), tileset.get_pattern(randi_range(0,20)))

func map_addBiomes():
	var org = generate_noise(o_type, o_gain, o_octaves, o_lacunarity, o_frequency)
	var size = generate_noise(s_type, s_gain, s_octaves, s_lacunarity, s_frequency)
	for x in width:
		for y in height:
			var pos = Vector2i(x,y)
			if org[pos] > 0.6 and size[pos] < 0.4:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(13,15), randi_range(0,2)), 0)
			if org[pos] > 0.8 and size[pos] > 0.95:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(13,15), randi_range(3,4)), 0)
			if org[pos] < 0.5 and size[pos] < 0.5:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(0,7), randi_range(20,21)), 0)

func map_addItems():
	for items in itemnumber:
		var item = item_scene.instantiate()
		item.item_position = Vector2i(randi_range(5,10),randi_range(5,10))
		item.position = tilemap.map_to_local(item.item_position)
		item.itemname = Item.itemtypes.key
		add_child(item)
	

func between(val, start, end):
	if start <= val and val < end:
		return true

func player_turn():
	playerdog.emit_signal("player_moved")

func update_position():
	playerdog.position = tilemap.map_to_local(playerdog.gridPosition)
	positionlabel.text = str(playerdog.gridPosition)

	
func test_cell(coords: Vector2i):
	var shift_jump = 1
	if Input.is_action_pressed("shift_jump"):
		shift_jump = playerdog.shift_move_multiplier
	else :
		shift_jump = 1
	var testingcell = playerdog.gridPosition + coords 
	var data = tilemap.get_cell_tile_data(0, testingcell)
	if data:
		if data.get_custom_data_by_layer_id(0) == 1: 
			if playerdog.walljump:
				playerdog.gridPosition += (-2 * coords)
				update_position()
			else:
				pass
		else: 
			var targetposition = playerdog.gridPosition + (coords * shift_jump)
			if test_for_goblin(targetposition) == false:
				playerdog.gridPosition = targetposition
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
		if is_instance_valid(goblin) and targetposition == goblin.enemy_position:
			goblin.health -= 1
			if goblin.health <= 0:
				goblin.queue_free()
				goblin_positions.erase(goblin)
				return false
			else:
				return true
	return false
